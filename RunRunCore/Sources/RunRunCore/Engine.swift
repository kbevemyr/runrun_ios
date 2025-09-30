import Foundation

public enum EngineState: Sendable {
	case stopped
	case running
	case paused
}

public final class Engine: @unchecked Sendable {
	private let workout: Workout
	private let notifier: Notifier?
	private var state: EngineState = .stopped
	private var currentSegmentIndex: Int = 0
	private var segmentStartTime: TimeInterval = 0
	private var pausedElapsed: TimeInterval = 0
	private let lock = NSLock()

	public init(workout: Workout, notifier: Notifier? = nil) {
		self.workout = workout
		self.notifier = notifier
	}

	public func start() {
		lock.lock()
		defer { lock.unlock() }
		// Om vi är klara, starta om från början
		if currentSegmentIndex >= workout.segments.count {
			currentSegmentIndex = 0
		}
		state = .running
		segmentStartTime = Date().timeIntervalSince1970
		pausedElapsed = 0
	}

	public func pause() {
		lock.lock()
		defer { lock.unlock() }
		guard state == .running else { return }
		state = .paused
		pausedElapsed += Date().timeIntervalSince1970 - segmentStartTime
	}

	public func resume() {
		lock.lock()
		defer { lock.unlock() }
		guard state == .paused else { return }
		state = .running
		segmentStartTime = Date().timeIntervalSince1970
	}

	public func skip() {
		lock.lock()
		defer { lock.unlock() }
		guard state == .running || state == .paused else { return }
		advanceToNextSegment()
	}

	public func back() {
		lock.lock()
		defer { lock.unlock() }
		guard state == .running || state == .paused else { return }
		guard currentSegmentIndex > 0 else { return }
		currentSegmentIndex -= 1
		segmentStartTime = Date().timeIntervalSince1970
		pausedElapsed = 0
	}

	public func restart() {
		lock.lock()
		defer { lock.unlock() }
		state = .stopped
		currentSegmentIndex = 0
		segmentStartTime = 0
		pausedElapsed = 0
	}

	public func getStatus(now: TimeInterval) -> Status {
		lock.lock()
		defer { lock.unlock() }
		
		print("🔍 getStatus() - State: \(state), SegmentIndex: \(currentSegmentIndex)")

		guard !workout.segments.isEmpty else {
			return Status(
				current: Status.Current(index: 0, type: .work, label: nil, seconds: 0, elapsed: 0, left: 0),
				progress: Status.Progress(intervalsDone: 0, intervalsLeft: 0, segmentsDone: 0, segmentsLeft: 0, timeLeft: 0, elapsedTotal: 0),
				next: nil
			)
		}

		// Kontrollera om workout är klar först
		//print("🔍 Kontrollerar Done-villkor: currentSegmentIndex=\(currentSegmentIndex), segments.count=\(workout.segments.count)")
		if currentSegmentIndex >= workout.segments.count {
			print("🎉 WORKOUT KLAR! - Sätter status till Done")
			state = .stopped
			let doneStatus = Status(
				current: Status.Current(
					index: 0, 
					type: .work, 
					label: "Done", 
					seconds: 0, 
					elapsed: 0, 
					left: 0
				),
				progress: Status.Progress(
					intervalsDone: workout.totals.totalIntervals, 
					intervalsLeft: 0, 
					segmentsDone: workout.segments.count, 
					segmentsLeft: 0, 
					timeLeft: 0, 
					elapsedTotal: workout.totals.totalSeconds
				),
				next: nil
			)
			//print("📊 Done-status returnerad - Label: \(doneStatus.current.label ?? "nil")")
			return doneStatus
		}

		// Kontrollera att currentSegmentIndex är giltigt
		guard currentSegmentIndex < workout.segments.count else {
			return Status(
				current: Status.Current(index: 0, type: .work, label: nil, seconds: 0, elapsed: 0, left: 0),
				progress: Status.Progress(intervalsDone: 0, intervalsLeft: 0, segmentsDone: 0, segmentsLeft: 0, timeLeft: 0, elapsedTotal: 0),
				next: nil
			)
		}
		
		let currentSegment = workout.segments[currentSegmentIndex]
		let segmentElapsed = state == .running ? now - segmentStartTime : 0
		let totalElapsed = pausedElapsed + segmentElapsed
		let segmentLeft = max(0, currentSegment.seconds - Int(segmentElapsed))

		// Beräkna progress
		let intervalsDone = workout.segments.prefix(currentSegmentIndex).filter { $0.type == .work }.count
		// Lägg till aktuellt work-segment om det är klart
		let currentIntervalsDone = intervalsDone + (currentSegment.type == .work && segmentLeft <= 0 ? 1 : 0)
		let intervalsLeft = workout.totals.totalIntervals - currentIntervalsDone
		let segmentsDone = currentSegmentIndex
		let segmentsLeft = workout.segments.count - currentSegmentIndex
		let timeLeft = workout.totals.totalSeconds - Int(totalElapsed)

		// Nästa segment
		let next: Status.Next? = {
			guard currentSegmentIndex + 1 < workout.segments.count else { return nil }
			let nextSegment = workout.segments[currentSegmentIndex + 1]
			return Status.Next(type: nextSegment.type, label: nextSegment.label, seconds: nextSegment.seconds)
		}()
		
		// Kontrollera om vi ska gå till nästa segment eller om workout är klart
		if state == .running && segmentLeft <= 0 {
			if currentSegmentIndex < workout.segments.count - 1 {
				//print("➡️ Går till nästa segment: \(currentSegmentIndex) -> \(currentSegmentIndex + 1)")
				advanceToNextSegment()
			} else {
				// Detta är det sista segmentet som är klart, markera workout som klar
				//print("🏁 Sista segmentet klart! Markerar workout som klar")
				currentSegmentIndex = workout.segments.count
				state = .stopped
			}
		}

		let status = Status(
			current: Status.Current(
				index: currentSegmentIndex,
				type: currentSegment.type,
				label: currentSegment.label,
				seconds: currentSegment.seconds,
				elapsed: Int(segmentElapsed),
				left: segmentLeft
			),
			progress: Status.Progress(
				intervalsDone: currentIntervalsDone,
				intervalsLeft: intervalsLeft,
				segmentsDone: segmentsDone,
				segmentsLeft: segmentsLeft,
				timeLeft: timeLeft,
				elapsedTotal: Int(totalElapsed)
			),
			next: next
		)
		
		//print("📊 Status returnerad - Label: \(status.current.label ?? "nil"), Left: \(status.current.left)s, Intervals: \(status.progress.intervalsDone)/\(status.progress.intervalsDone + status.progress.intervalsLeft)")
		
		return status
	}

	private func advanceToNextSegment() {
		// Kontrollera att currentSegmentIndex är giltigt innan vi använder det
		guard currentSegmentIndex < workout.segments.count else { return }
		
		let previousType = workout.segments[currentSegmentIndex].type
		currentSegmentIndex += 1
		segmentStartTime = Date().timeIntervalSince1970
		pausedElapsed = 0

		// Notifiera om övergång
		if currentSegmentIndex >= workout.segments.count {
			// Workout är klart - stanna här
			state = .stopped
			notifier?.notifyTransition(.end)
		} else if currentSegmentIndex < workout.segments.count {
			let currentType = workout.segments[currentSegmentIndex].type
			let transitionKind: TransitionKind = {
				switch (previousType, currentType) {
				case (.prepare, .work): return .prepareToWork
				case (.work, .rest): return .workToRest
				case (.rest, .work): return .restToWork
				default: return .prepareToWork // fallback
				}
			}()
			notifier?.notifyTransition(transitionKind)
		}
	}
}

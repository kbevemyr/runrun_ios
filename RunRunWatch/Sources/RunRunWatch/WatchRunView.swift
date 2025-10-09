import SwiftUI
import Combine
import RunRunCore

#if os(watchOS)
public struct WatchRunView: View {
	@StateObject private var vm: WatchRunViewModel
	public init(workout: Workout) {
		_vm = StateObject(wrappedValue: WatchRunViewModel(workout: workout))
	}
	
	public var body: some View {
		VStack(spacing: 8) {
			Text(vm.status.current.type.rawValue.capitalized)
				.font(.headline)
			if let label = vm.status.current.label {
				Text(label)
					.font(.caption)
					.foregroundColor(.secondary)
			}
			
			Text(timeString(vm.status.current.left))
				.font(.system(size: 48, weight: .bold, design: .rounded))
				.monospacedDigit()
			
			Text("\(vm.status.progress.intervalsDone)/\(vm.status.progress.intervalsLeft + vm.status.progress.intervalsDone)")
				.font(.caption)
			
			HStack(spacing: 8) {
				Button(vm.isRunning ? "Pausa" : "Start") {
					vm.isRunning ? vm.pause() : vm.start()
				}
				Button("Hoppa") { vm.skip() }
			}
		}
		.padding()
	}
	
	private func timeString(_ seconds: Int) -> String {
		let m = seconds / 60
		let s = seconds % 60
		return String(format: "%02d:%02d", m, s)
	}
}

public final class WatchRunViewModel: ObservableObject {
	@Published public private(set) var status: Status
	@Published public private(set) var isRunning: Bool = false

	private let workout: Workout
	private let engine: Engine
	private var timerCancellable: AnyCancellable?

	public init(workout: Workout) {
		self.workout = workout
		self.engine = Engine(workout: workout, notifier: WatchOSNotifier())
		self.status = Status(
			current: .init(index: 0, type: .prepare, label: nil, seconds: 0, elapsed: 0, left: 0),
			progress: .init(intervalsDone: 0, intervalsLeft: 0, segmentsDone: 0, segmentsLeft: 0, timeLeft: 0, elapsedTotal: 0),
			next: nil
		)
	}

	public func start() {
		engine.start()
		isRunning = true
		startTimer()
	}

	public func pause() {
		engine.pause()
		isRunning = false
	}

	public func skip() { engine.skip() }

	private func startTimer() {
		timerCancellable?.cancel()
		timerCancellable = Timer.publish(every: 0.2, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				guard let self else { return }
				let now = Date().timeIntervalSince1970
				self.status = self.engine.getStatus(now: now)
			}
	}
}

// MARK: - Preview

#if DEBUG
#Preview("Running Workout", traits: .fixedLayout(width: 205, height: 251)) {
	let workout = try! ProgramParser().parse("W60 R30 W60 R30")
	WatchRunView(workout: workout)
		.previewDevice(PreviewDevice(rawValue: "Apple Watch Series 9 (45mm)"))
}

#Preview("With Label", traits: .fixedLayout(width: 205, height: 251)) {
	let workout = try! ProgramParser().parse("W30/warmup R60/sprint W30/cooldown")
	WatchRunView(workout: workout)
		.previewDevice(PreviewDevice(rawValue: "Apple Watch Series 9 (45mm)"))
}

#Preview("Long Intervals", traits: .fixedLayout(width: 176, height: 215)) {
	let workout = try! ProgramParser().parse("W120 R180 W120 R180 W120")
	WatchRunView(workout: workout)
		.previewDevice(PreviewDevice(rawValue: "Apple Watch SE (40mm)"))
}
#endif

#endif

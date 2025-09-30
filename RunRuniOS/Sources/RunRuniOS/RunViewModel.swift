import Foundation
import Combine
import RunRunCore

#if os(iOS)

public final class RunViewModel: ObservableObject {
	@Published public private(set) var status: Status
	@Published public private(set) var isRunning: Bool = false

	private let workout: Workout
	private let engine: Engine
	private var timerCancellable: AnyCancellable?

	public init(workout: Workout, notifier: Notifier? = nil) {
		self.workout = workout
		self.engine = Engine(workout: workout, notifier: notifier)
		// Hämta initial status från engine istället för hårdkodade värden
		self.status = engine.getStatus(now: Date().timeIntervalSince1970)
	}

	public func start() {
		guard !isRunning else { return }
		engine.start()
		isRunning = true
		startTimer()
	}

	public func pause() {
		engine.pause()
		isRunning = false
	}

	public func resume() {
		guard !isRunning else { return }
		engine.resume()
		isRunning = true
	}

	public func skip() { engine.skip() }
	public func back() { engine.back() }
	public func restart() { engine.restart() }

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
#endif

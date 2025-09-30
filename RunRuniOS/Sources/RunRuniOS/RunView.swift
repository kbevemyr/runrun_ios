import SwiftUI
import RunRunCore

#if os(iOS)

public struct RunView: View {
	@StateObject private var vm: RunViewModel
	private let workout: Workout
	private let onBackToStart: (() -> Void)?
	
	public init(workout: Workout, onBackToStart: (() -> Void)? = nil) {
		self.workout = workout
		self.onBackToStart = onBackToStart
		_vm = StateObject(wrappedValue: RunViewModel(workout: workout, notifier: iOSNotifier()))
	}
	public var body: some View {
		VStack(spacing: 16) {
			// Done status
			if vm.status.current.label == "Done" {
				VStack(spacing: 20) {
					Text("🎉")
						.font(.system(size: 80))
					Text("Workout Klar!")
						.font(.largeTitle)
						.fontWeight(.bold)
						.foregroundColor(.green)
					Text("Alla \(vm.status.progress.intervalsDone) intervals genomförda")
						.font(.headline)
						.foregroundColor(.secondary)
				}
			} else {
				// Normal workout view
				VStack(spacing: 20) {
					Text(timeString(vm.status.progress.elapsedTotal))
						.font(.system(size: 24, weight: .bold, design: .rounded))
						.monospacedDigit()
						.foregroundColor(.secondary)
					VStack(spacing: 8) {
						Text("Total tid: \(timeString(vm.status.progress.elapsedTotal))")
							.font(.headline)
							.foregroundColor(.secondary)
						Text("Intervall \(currentIntervalNumber) av \(totalIntervals)")
							.font(.headline)
							.foregroundColor(.secondary)
						Text("Tid kvar: \(timeString(vm.status.progress.timeLeft))")
							.font(.headline)
							.foregroundColor(.secondary)
					}
					
					// Current Interval Info
					VStack(spacing: 8) {
						Text("Intervall \(currentIntervalNumber) av \(totalIntervals)")
							.font(.headline)
							.foregroundColor(.secondary)
						
						Text(vm.status.current.type.rawValue.capitalized)
							.font(.largeTitle)
							.fontWeight(.bold)
							.foregroundColor(vm.status.current.type == .work ? .red : .blue)
						
						if let label = vm.status.current.label { 
							Text(label)
								.font(.title2)
								.foregroundColor(.secondary)
						}
					}
					
					// Timer
					Text(timeString(vm.status.current.left))
						.font(.system(size: 64, weight: .bold, design: .rounded))
						.monospacedDigit()
						.foregroundColor(vm.status.current.left <= 5 ? .red : .primary)

					// Progress Info
					VStack(spacing: 8) {
						HStack {
							Text("Tid kvar: \(timeString(vm.status.progress.timeLeft))")
							Spacer()
							Text("Segment \(segmentDisplayText)")
						}
						.font(.subheadline)
						.foregroundColor(.secondary)

						if let next = vm.status.next {
							HStack {
								Text("Nästa: \(next.type.rawValue.capitalized)")
								Spacer()
								Text("\(next.seconds)s")
							}
							.font(.subheadline)
							.foregroundColor(.secondary)
						}
					}
				}
			}

			// Kontroller (dölj om workout är klar)
			if vm.status.current.label != "Done" {
				HStack(spacing: 12) {
					Button(vm.isRunning ? "Pausa" : "Start") {
						if vm.isRunning {
							vm.pause()
						} else {
							vm.start()
						}
					}.buttonStyle(.borderedProminent)
					Button("Fortsätt") { vm.resume() }
					Button("Bakåt") { vm.back() }
					Button("Hoppa över") { vm.skip() }
				}
			} else {
				// Done-kontroller
				VStack(spacing: 16) {
					Button("Starta om") {
						vm.restart()
					}
					.buttonStyle(.borderedProminent)
					.frame(maxWidth: .infinity)
					.padding()
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(12)
					
				}
				.padding(.horizontal)
			}
		}
		.padding()
		.navigationTitle("Kör")
	}

	private func timeString(_ seconds: Int) -> String {
		let m = seconds / 60
		let s = seconds % 60
		return String(format: "%02d:%02d", m, s)
	}
	
	private var currentIntervalNumber: Int {
		// Om workout är klart, visa totalt antal intervals
		if vm.status.current.label == "Done" {
			return vm.status.progress.intervalsDone
		}
		
		// Beräkna vilket interval vi är på baserat på work-segments
		let workSegmentsBeforeCurrent = vm.status.current.index > 0 ? 
			workout.segments.prefix(vm.status.current.index).filter { $0.type == .work }.count : 0
		
		// Om vi är på ett work-segment, räkna det som nästa interval
		if vm.status.current.type == .work {
			return workSegmentsBeforeCurrent + 1
		}
		
		// Om vi är på rest efter work, vi är fortfarande på samma interval
		return workSegmentsBeforeCurrent
	}
	
	private var totalIntervals: Int {
		// Om workout är klart, använd intervalsDone
		if vm.status.current.label == "Done" {
			return vm.status.progress.intervalsDone
		}
		
		return vm.status.progress.intervalsLeft + vm.status.progress.intervalsDone
	}
	
	private var segmentDisplayText: String {
		// Om workout är klart, visa totalt antal segments
		if vm.status.current.label == "Done" {
			let totalSegments = vm.status.progress.segmentsDone + vm.status.progress.segmentsLeft
			return "\(totalSegments) av \(totalSegments)"
		}
		
		let currentSegment = vm.status.current.index + 1
		let totalSegments = vm.status.progress.segmentsDone + vm.status.progress.segmentsLeft
		return "\(currentSegment) av \(totalSegments)"
	}
}
#endif

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
					Text("Workout Done!")
						.font(.largeTitle)
						.fontWeight(.bold)
						.foregroundColor(.green)
                    Text("Alla \(vm.status.progress.intervalsDone) intervals are done in \(workout.totals.totalSeconds)")
						.font(.headline)
						.foregroundColor(.secondary)
				}
			} else {
				// Normal workout view
				VStack(spacing: 180) {
                    
					// Progress bar of workout
                    GeometryReader {
                        geo in
                        VStack(spacing: 4) {
                            
                            HStack {
                                Spacer()
                                Text("Interval \(currentIntervalNumber) of \(totalIntervals)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            var progress: Double = Double(workout.totals.totalSeconds-vm.status.progress.timeLeft)/Double(workout.totals.totalSeconds)
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.3))
                                    .frame(width: geo.size.width, height: 8)
                                Rectangle()
                                    .foregroundColor(.blue)
                                    .frame(width: geo.size.width * CGFloat(progress), height: 8)
                                    .animation(.easeInOut(duration: progress))
                            }
                            .cornerRadius(4)
                            
                            HStack {
                                Spacer()
                                Text("Time \(timeString(workout.totals.totalSeconds-vm.status.progress.timeLeft)) /  \(timeString(workout.totals.totalSeconds))")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    
					// Current Segment Info
					VStack(spacing: 8) {
                        // Running time
                        Text(timeString(vm.status.current.left))
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(vm.status.current.left <= 5 ? .red : .primary)
                        
						
                        // Prepare/Work/Rest/label
                        HStack {
                            Text("\(vm.status.current.label ?? vm.status.current.type.rawValue.capitalized) \(timeString(vm.status.current.seconds))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(vm.status.current.type == .work ? .red : .blue)
                        }
                        
                        Text("Segment \(segmentDisplayText)")
					}
					

					// Progress Info
					VStack(spacing: 8) {

						if let next = vm.status.next {
							HStack {
								Text("Next:")
                                    .font(.title)
                                Text("\(next.label ?? next.type.rawValue.capitalized) \(timeString(next.seconds))")
                                    .font(.title)
                                    .fontWeight(.light)
                                    .foregroundColor(next.type == .work ? .red : .blue)
							}
							.font(.headline)
							.foregroundColor(.secondary)
						}
					}
				}
			}

			// Kontroller (dölj om workout är klar)
            Spacer()
			if vm.status.current.label != "Done" {
				HStack(spacing: 12) {
					Button(
						action: { 
							if vm.isRunning {
								vm.pause()
							} else {
								vm.start()
							}
						})
						{
                            Image(systemName: {
                                vm.isRunning ? "pause.fill" : "play.fill"}())
                        }
                        .help("playing")
					
                    // kbb added - be able to restart the timer at anytime
                    Button {
                        vm.restart()
                    } label: {
						Image(systemName: "arrow.counterclockwise.circle")
						.help("Reset")
                    }
					Button {
                        vm.back()
                    } label: {
                        Image(systemName: "backward.fill")
						.help("Back")
                    }
					
                    Button {
                        vm.skip()
                    } label: {
                        Image(systemName: "forward.fill")
						.help("Skip")
                    }
					
				}
			} else {
				// Done-kontroller
				VStack(spacing: 16) {
					Button("Reset") {
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
		.navigationTitle("Run")
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

		let currentSegment = vm.status.current.index
		let totalSegments = vm.status.progress.segmentsDone + vm.status.progress.segmentsLeft
		return "\(currentSegment) av \(totalSegments)"
	}
}
 
#if DEBUG
#Preview {
	NavigationView {
		RunView(workout: sampleWorkout)
	}
}

private var sampleWorkout: Workout {
	let parser = ProgramParser()
	return try! parser.parse("P5 (x2 W20@VO2 R10)")
}
#endif
#endif

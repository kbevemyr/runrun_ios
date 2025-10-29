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
		GeometryReader { geometry in
			let isLandscape = geometry.size.width > geometry.size.height
			
			if vm.status.current.label == "Done" {
				// Done status
				VStack(spacing: 20) {
					Text("🎉")
						.font(.system(size: isLandscape ? 60 : 80))
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
				if isLandscape {
					// Landscape layout
					HStack(spacing: 20) {
						// Left side - Progress and info
						VStack(spacing: 16) {
							// Progress bar
							VStack(spacing: 4) {
								
								let progress: Double = Double(workout.totals.totalSeconds-vm.status.progress.timeLeft)/Double(workout.totals.totalSeconds)
								let barHeight = Double(12)
								
								// Segment rektanglar med progress overlay
								ZStack(alignment: .leading) {
									// Segment rektanglar
									HStack(spacing: 0) {
										ForEach(workout.segments, id: \.index) { segment in
											let segmentWidth = CGFloat(segment.seconds) / CGFloat(workout.totals.totalSeconds) * geometry.size.width * 0.4
											Rectangle()
												.foregroundColor(segmentColor(for: segment.type))
												.frame(width: segmentWidth, height: barHeight)
										}
									}
									
									// Grå overlay för att visa framsteg
									Rectangle()
										.foregroundColor(.gray.opacity(0.7))
										.frame(width: geometry.size.width * 0.4 * CGFloat(progress), height: barHeight)
										.animation(.easeInOut, value: progress)
								}
								.cornerRadius(4)
								
								VStack {
									Text("Time \(timeString(workout.totals.totalSeconds-vm.status.progress.timeLeft)) /  \(timeString(workout.totals.totalSeconds))")
                                    Text("Interval \(currentIntervalNumber) of \(totalIntervals)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
								}
								.font(.caption)
								.foregroundColor(.secondary)
							}
							
							// Next segment info
							if let next = vm.status.next {
								VStack {
									HStack {
										Text("Next:")
											.font(.title2)
										Text("\(next.label ?? next.type.rawValue.capitalized) \(timeString(next.seconds))")
											.font(.title2)
											.foregroundColor(segmentColor(for: next.type))
									}
									.font(.headline)
									.foregroundColor(.secondary)
								}
								.padding(8)
							}
							
							Spacer()
						}
						.frame(width: geometry.size.width * 0.4)
						
						// Right side - Main timer card
						VStack {
							Spacer()
                            Button {
                                vm.restart()
                            } label: {
                                Image(systemName: "arrow.counterclockwise.circle")
                                .help("Reset")
                            }
                            Spacer()
							
							VStack(spacing: 16) {
								// Running time
								Text(timeString(vm.status.current.left))
									.font(.system(size: isLandscape ? 72 : 96, weight: .bold, design: .rounded))
									.monospacedDigit()
									.foregroundColor(vm.status.current.left <= 5 ? .secondary : .primary)
								
								// Prepare/Work/Rest/label
								HStack {
									Text("\(vm.status.current.label ?? vm.status.current.type.rawValue.capitalized) \(timeString(vm.status.current.seconds))")
										.font(.title2)
										.fontWeight(.bold)
										.foregroundColor(segmentColor(for: vm.status.current.type))
								}
								
								Text("Segment \(segmentDisplayText)")
									.font(.headline)
									.foregroundColor(.secondary)
							}
							.padding(24)
							.background(
								RoundedRectangle(cornerRadius: 16)
									.fill(.regularMaterial)
									.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
							)
							
							Spacer()
							
							// Controls
							VStack(spacing: 16) {
								
								// Kontroll-knappar
                                let buttonSize = Double(isLandscape ? 32 : 48)
								HStack(spacing: 12) {
									Button {
										vm.back()
									} label: {
										Image(systemName: "backward.fill")
										.help("Back")
									}
									Spacer()
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
                                                .font(.system(size: buttonSize, weight: .medium))
                                        }
                                        .help("playing")
									Spacer()
									Button {
										vm.skip()
									} label: {
										Image(systemName: "forward.fill")
										.help("Skip")
									}
								}
                                .font(.system(size: buttonSize*0.75, weight: .medium))
							}
						}
						.frame(width: geometry.size.width * 0.6)
					}
				} else {
					// Portrait layout
					VStack() {
                    
						// Progress bar of workout
						GeometryReader { geo in
							VStack(spacing: 4) {
								
								HStack {
									Text("Interval \(currentIntervalNumber) of \(totalIntervals)")
										.font(.caption)
										.foregroundColor(.secondary)
									Spacer()
								}
								let progress: Double = Double(workout.totals.totalSeconds-vm.status.progress.timeLeft)/Double(workout.totals.totalSeconds)
								let barHeight = Double(12)
								
								// Segment rektanglar med progress overlay
								ZStack(alignment: .leading) {
									// Segment rektanglar
									HStack(spacing: 0) {
										ForEach(workout.segments, id: \.index) { segment in
											let segmentWidth = CGFloat(segment.seconds) / CGFloat(workout.totals.totalSeconds) * geo.size.width
											Rectangle()
												.foregroundColor(segmentColor(for: segment.type))
												.frame(width: segmentWidth, height: barHeight)
										}
									}
									
									// Grå overlay för att visa framsteg
									Rectangle()
										.foregroundColor(.gray.opacity(0.7))
										.frame(width: geo.size.width * CGFloat(progress), height: barHeight)
										.animation(.easeInOut, value: progress)
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
						
						// Current Segment Info Card
						VStack {
							Spacer()
							
							VStack(spacing: 16) {
								// Running time
								Text(timeString(vm.status.current.left))
									.font(.system(size: 96, weight: .bold, design: .rounded))
									.monospacedDigit()
									.foregroundColor(vm.status.current.left <= 5 ? .secondary : .primary)
								
								// Prepare/Work/Rest/label
								HStack {
									Text("\(vm.status.current.label ?? vm.status.current.type.rawValue.capitalized) \(timeString(vm.status.current.seconds))")
										.font(.title)
										.fontWeight(.bold)
										.foregroundColor(segmentColor(for: vm.status.current.type))
								}
								
								Text("Segment \(segmentDisplayText)")
									.font(.headline)
									.foregroundColor(.secondary)
							}
							.padding(24)
							.background(
								RoundedRectangle(cornerRadius: 16)
									.fill(.regularMaterial)
									.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
							)
							
							Spacer()
						}
						
						// Progress Info
						VStack() {
							if let next = vm.status.next {
								HStack {
									Text("Next:")
										.font(.title)
									Text("\(next.label ?? next.type.rawValue.capitalized) \(timeString(next.seconds))")
										.font(.title)
										.foregroundColor(segmentColor(for: next.type))
								}
								.font(.headline)
								.foregroundColor(.secondary)
							}
						}
						.padding(8)
						
						Spacer()
						
						// Kontroller
						if vm.status.current.label != "Done" {
							VStack(spacing: 16) {
								// Centrerad play/pause knapp
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
											.font(.system(size: 48, weight: .medium))
									}
									.help("playing")
								
								// Kontroll-knappar
								HStack(spacing: 12) {
									Button {
										vm.back()
									} label: {
										Image(systemName: "backward.fill")
										.help("Back")
									}
									Spacer()
									Button {
										vm.restart()
									} label: {
										Image(systemName: "arrow.counterclockwise.circle")
										.help("Reset")
									}
									Spacer()
									Button {
										vm.skip()
									} label: {
										Image(systemName: "forward.fill")
										.help("Skip")
									}
								}
								.font(.system(size: 32, weight: .medium))
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
				}
			}
		}
		.padding()
		.navigationTitle("Run Timer")
	}

	private func timeString(_ seconds: Int) -> String {
		let m = seconds / 60
		let s = seconds % 60
		return String(format: "%02d:%02d", m, s)
	}
	
	private func segmentColor(for type: SegmentType) -> Color {
		switch type {
		case .work:
			return Color("WorkColor")
		case .prepare:
			return Color("PrepareColor")
		case .rest:
			return Color("RestColor")
		}
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
	return try! parser.parse("P5 (x12 W20@VO2 R10)")
}
#endif
#endif

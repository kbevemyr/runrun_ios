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
				doneView(isLandscape: isLandscape)
			} else {
				if isLandscape {
					landscapeLayout(geometry: geometry)
				} else {
					portraitLayout(geometry: geometry)
				}
			}
		}
		.padding()
		.navigationTitle("Run Timer")
	}
	
	// MARK: - Done View
	private func doneView(isLandscape: Bool) -> some View {
		VStack(spacing: 20) {
			Text("🎉")
				.font(.system(size: isLandscape ? 60 : 80))
			Text("Workout Done!")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundColor(.green)
			Text("Alla \(vm.status.progress.intervalsDone) intervals are done in \(timeString(workout.totals.totalSeconds))")
				.font(.headline)
				.foregroundColor(.secondary)
			
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
	}
	
	// MARK: - Portrait Layout
	private func portraitLayout(geometry: GeometryProxy) -> some View {
		VStack(spacing: 12) {
            // Main Timer with circular progress
            timerSection
            
            // Progress and Status
            progressSection
			
			// Controls
			controlsSection
            Spacer()
		}
	}
	
	// MARK: - Landscape Layout
	private func landscapeLayout(geometry: GeometryProxy) -> some View {
		VStack(spacing: 0) {

            progressBar
            .padding(.horizontal)
			
            HStack(alignment: .top, spacing: 12) {
				// Left side - Timer
				VStack() {
                    Spacer()
					timerSection
					controlsSection
                    Spacer()
				}
				.frame(maxWidth: .infinity)
				
				// Right side - Info
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        // Interval counter
                        statusCard
                                        
                        // Next segment
                        nextSegmentCompactCard
                    }
                                    
                    // Upcoming segments
                    upcomingSegmentsList
                                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
			}
            .padding()
		}
	}
	
	// MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 16) {
            
            // Next segment
            nextSegmentCard
            
            // Upcoming segments
            upcomingSegmentsList
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
	}
    
    private var progressBar: some View {
        // Segment progress bar
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                let progress: Double = Double(workout.totals.totalSeconds - vm.status.progress.timeLeft) / Double(workout.totals.totalSeconds)
                Rectangle()
                    .fill(Color.green)
                    .frame(width: geo.size.width * CGFloat(progress), height: 8)
                    .cornerRadius(4)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 8)
    }
	
	// MARK: - Timer Section
	private var timerSection: some View {
		VStack(spacing: 16) {
            
			// Circular progress with timer
			ZStack {
				Circle()
					.stroke(Color.gray.opacity(0.2), lineWidth: 12)
					.frame(width: 240, height: 240)
				
				let progress = Double(vm.status.current.left) / Double(vm.status.current.seconds)
				Circle()
					.trim(from: 0, to: CGFloat(progress))
					.stroke(segmentColor(for: vm.status.current.type), style: StrokeStyle(lineWidth: 12, lineCap: .round))
					.frame(width: 240, height: 240)
					.rotationEffect(.degrees(-90))
					.animation(.easeInOut, value: progress)
				
                VStack(spacing: 0) {
                    Text(timeString(vm.status.current.left))
                        .font(.system(size: 72, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                    Text(vm.status.current.label ?? vm.status.current.type.rawValue.capitalized)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(segmentColor(for: vm.status.current.type))
                }

			}
		}
	}
	
	// MARK: - Status Card
    var statusCard: some View {
        VStack(spacing: 8) {
            Text("Status")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            Text("\(currentIntervalNumber) av \(totalIntervals)")
            Text("\(timeString(workout.totals.totalSeconds - vm.status.progress.timeLeft)) / \(timeString(workout.totals.totalSeconds))")
            // Segment counter badge
            Text("Segment \(segmentDisplayText)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
    
    // MARK: - Next Segment Card
	private var nextSegmentCard: some View {
        let nexti = vm.status.next
        
        return HStack(spacing: 16) {
			VStack(alignment: .leading, spacing: 4) {
				Text("Nästa")
					.font(.caption)
					.foregroundColor(.secondary)
				if let next = vm.status.next {
					Text(next.label ?? next.type.rawValue.capitalized)
						.font(.title3)
						.fontWeight(.semibold)
				}
			}
			
			Spacer()
			
			if let next = vm.status.next {
				Text(timeString(next.seconds))
					.font(.system(size: 32, weight: .semibold, design: .rounded))
					//.foregroundColor(segmentColor(for: next.type))
			}
		}
		.padding()
		//.background(Color.gray.opacity(0.1))
		.cornerRadius(16)
	}
    
    var nextSegmentCompactCard: some View {
            VStack(spacing: 8) {
                Text("Nästa")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                if let next = vm.status.next {
                    Text(next.label ?? next.type.rawValue.capitalized)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.red)
                }
                    
                if let next = vm.status.next {
                    Text(timeString(next.seconds))
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.yellow)
                        .monospacedDigit()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
	
	// MARK: - Upcoming Segments List
	private var upcomingSegmentsList: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Kommande")
				.font(.caption)
				.foregroundColor(.secondary)
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Array(workout.segments.enumerated().dropFirst(vm.status.current.index + 1).prefix(3)), id: \.offset) { index, segment in
                        HStack {
                            Text(segment.label ?? segment.type.rawValue.capitalized)
                                .font(.subheadline)
                            Spacer()
                            Text(timeString(segment.seconds))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
		}
		.padding()
		.background(Color.gray.opacity(0.1))
		.cornerRadius(16)
	}
	
	// MARK: - Controls Section
	private var controlsSection: some View {
		VStack(spacing: 20) {
			// Main play/pause button
			Button(action: {
				if vm.isRunning {
					vm.pause()
				} else {
					vm.start()
				}
			}) {
				Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
					.font(.system(size: 32))
					.foregroundColor(.white)
					.frame(width: 80, height: 80)
					.background(Color.blue)
					.clipShape(Circle())
					.shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
			}
			
			// Secondary controls
			HStack(spacing: 32) {
				Button(action: { vm.back() }) {
					VStack(spacing: 4) {
						Image(systemName: "backward.fill")
							.font(.system(size: 24))
						Text("Föregående")
							.font(.caption2)
					}
					.foregroundColor(.blue)
				}
				
				Button(action: { vm.restart() }) {
					VStack(spacing: 4) {
						Image(systemName: "arrow.clockwise")
							.font(.system(size: 24))
						Text("Starta om")
							.font(.caption2)
					}
					.foregroundColor(.blue)
				}
				
				Button(action: { vm.skip() }) {
					VStack(spacing: 4) {
						Image(systemName: "forward.fill")
							.font(.system(size: 24))
						Text("Hoppa över")
							.font(.caption2)
					}
					.foregroundColor(.blue)
				}
			}
		}
	}

	// MARK: - Helper Functions
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
	return try! parser.parse("P5 (x12 W4@VO2 R3)")
}
#endif
#endif

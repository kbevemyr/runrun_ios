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
		.toolbar {
            ToolbarItem(placement: .automatic) {
				Button("Reset") {
					vm.restart()
				}
			}
		}
	}
	
	// MARK: - Done View
	private func doneView(isLandscape: Bool) -> some View {
		VStack(spacing: 20) {
			Text("Workout Done!")
				.font(.largeTitle)
				.fontWeight(.bold)
			Text("All \(vm.status.progress.intervalsDone) intervals are done in \(workout.totals.totalSeconds.timeString)")
				.font(.headline)
				.foregroundColor(.secondary)
			
			Button("Done") {
				vm.restart()
			}
			.buttonStyle(.borderedProminent)
			.frame(maxWidth: .infinity)
			.padding()
			.cornerRadius(16)
		}
	}
	
	// MARK: - Portrait Layout
	private func portraitLayout(geometry: GeometryProxy) -> some View {
		VStack(spacing: 12) {
            // Main Timer with circular progress
            timerSection
            
            // Progress and Status
            progressSection
            statusCard
			
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
                    // Upcoming segments
                    upcomingSegmentsList
                    
                    HStack(spacing: 16) {
                        // Interval counter
                        statusCard
                    }
                                    
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
            // Upcoming segments
            upcomingSegmentsList
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
            //let _progress = Double(vm.status.current.left) / Double(vm.status.current.seconds)
            
            VStack(spacing: 0) {
                Text(vm.status.current.left.timeString)
                    .font(.system(size: 72, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                Text(vm.status.current.label ?? vm.status.current.type.rawValue.capitalized)
                    .font(.system(size: 36, weight: .bold))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(segmentColor(for: vm.status.current.type))
        .cornerRadius(16)
	}
	
	// MARK: - Status Card
    var statusCard: some View {
        HStack(spacing: 8) {
            Text("Status")
                    .fontWeight(.semibold)
            Spacer()
            Text("\((workout.totals.totalSeconds - vm.status.progress.timeLeft).timeString) / \(workout.totals.totalSeconds.timeString)")
            Spacer()
            Text("\(currentIntervalNumber) av \(totalIntervals)")
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
    
	
	// MARK: - Upcoming Segments List
	private var upcomingSegmentsList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(Array(workout.segments.enumerated().dropFirst(vm.status.current.index+1)), id: \.offset) { index, segment in
                    HStack {
                        Text(segment.label ?? segment.type.rawValue.capitalized)
                            .font(.subheadline)
                        Spacer()
                        Text(segment.seconds.timeString)
                            .font(.subheadline)
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(segmentColor(for: segment.type))
                    .cornerRadius(16)
                }
            }
        }
	}
	
	// MARK: - Controls Section
	private var controlsSection: some View {
        HStack(spacing: 32) {
            Button(action: { vm.back() }) {
                VStack(spacing: 4) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 24))
                }
                .foregroundColor(.accent)
            }
            
            // Main play/pause button
            PlayButton(isRunning: vm.isRunning, action:  {
                if vm.isRunning {
                    vm.pause()
                } else {
                    vm.start()
                }
            }, size: .large)
            
            Button(action: { vm.skip() }) {
                VStack(spacing: 4) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 24))
                }
                .foregroundColor(.accent)
            }
        }
        .padding()
	}

	// MARK: - Helper Functions
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
	return try! parser.parse("P5 (x4 W4@VO2 R3)")
}
#endif
#endif

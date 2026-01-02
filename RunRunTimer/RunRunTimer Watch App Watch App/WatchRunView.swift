import SwiftUI
import Combine
import RunRunCore

#if os(watchOS)
public struct WatchRunView: View {
	@StateObject private var vm: WatchRunViewModel
	@State private var selectedTab = 1 // Start on center page
	private let workout: Workout
	
	public init(workout: Workout) {
		self.workout = workout
		_vm = StateObject(wrappedValue: WatchRunViewModel(workout: workout))
	}
	
	public var body: some View {
		if vm.status.current.label == "Done" {
			doneView
		} else {
			TabView(selection: $selectedTab) {
				// Left page - Controls
				controlsPage
					.tag(0)
				
				// Center page - Main Run View
				mainRunView
					.tag(1)
				
				// Right page - Status
				statusPage
					.tag(2)
			}
			.tabViewStyle(.page)
		}
	}
	
	// MARK: - Main Run View (Center)
	private var mainRunView: some View {
		ScrollView {
			VStack(spacing: 3) {
				// Main Timer with color background
				timerSection
				
				// Upcoming segments
				upcomingSegmentsList
			}
			.padding()
		}
	}
	
	// MARK: - Controls Page (Left)
	private var controlsPage: some View {
		ScrollView {
			VStack(spacing: 16) {
				
				// Main play/pause button
				Button(action: {
					if vm.isRunning {
						vm.pause()
					} else {
						vm.start()
					}
				}) {
					VStack(spacing: 8) {
						Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
							.font(.system(size: 28))
							.foregroundColor(.white)
							.frame(width: 42, height: 42)
							.background(.accent)
							.clipShape(Circle())
						Text(vm.isRunning ? "Pausa" : "Starta")
							.font(.caption)
							.fontWeight(.semibold)
					}
				}
				.buttonStyle(.plain)
				
				
				// Restart button
				Button(action: { vm.restart() }) {
					VStack(spacing: 6) {
						Image(systemName: "arrow.counterclockwise")
							.font(.system(size: 28))
							.foregroundColor(.white)
							.frame(width: 42, height: 42)
							.background(Color.orange)
							.clipShape(Circle())
						Text("Starta om")
							.font(.caption)
							.fontWeight(.semibold)
					}
				}
				.buttonStyle(.plain)
				
				Spacer()
			}
			.padding()
		}
	}
	
	// MARK: - Status Page (Right)
	private var statusPage: some View {
		ScrollView {
			VStack() {
				// Time progress
				VStack() {
					Text("Tid")
						.font(.caption)
						.foregroundColor(.secondary)
					Text("\(timeString(workout.totals.totalSeconds - vm.status.progress.timeLeft)) / \(timeString(workout.totals.totalSeconds))")
						.font(.title3)
						.fontWeight(.semibold)
						.monospacedDigit()
				}
				
                Spacer()
                
				// Interval progress
				VStack() {
					Text("Intervall")
						.font(.caption)
						.foregroundColor(.secondary)
					Text("\(currentIntervalNumber) av \(totalIntervals)")
						.font(.title3)
						.fontWeight(.semibold)
				}
                
				Spacer()
                
				// Segments progress
				VStack() {
					Text("Segment")
						.font(.caption)
						.foregroundColor(.secondary)
					Text("\(vm.status.progress.segmentsDone) av \(vm.status.progress.segmentsDone + vm.status.progress.segmentsLeft)")
						.font(.title3)
						.fontWeight(.semibold)
				}
			}
            .padding()
		}
	}
	
	// MARK: - Done View
	private var doneView: some View {
		VStack(spacing: 12) {
			Text("Done")
				.font(.system(size: 32, weight: .bold))
			Text("All \(vm.status.progress.intervalsDone) intervals are done in \(timeString(workout.totals.totalSeconds))")
				.font(.caption)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
			
			Button("Reset") {
				vm.restart()
			}
			.buttonStyle(.borderedProminent)
		}
		.padding()
	}
	
	// MARK: - Timer Section
	private var timerSection: some View {
		Button(action: {
			if vm.isRunning {
				vm.pause()
			} else {
				vm.start()
			}
		}) {
			VStack(spacing: 4) {
				Text(timeString(vm.status.current.left))
					.font(.system(size: 56, weight: .medium, design: .rounded))
					.monospacedDigit()
					.foregroundColor(.primary)
				Text(vm.status.current.label ?? vm.status.current.type.rawValue.capitalized)
					.font(.system(size: 16, weight: .bold))
					.foregroundColor(.primary)
			}
			.frame(maxWidth: .infinity)
			.padding(.vertical, 12)
			.padding(.horizontal, 8)
			.background(segmentColor(for: vm.status.current.type))
			.cornerRadius(12)
		}
		.buttonStyle(.plain)
	}
	
	// MARK: - Upcoming Segments List
	private var upcomingSegmentsList: some View {
		VStack(alignment: .leading, spacing: 4) {
			ScrollView {
				VStack(spacing: 4) {
					ForEach(Array(workout.segments.enumerated().dropFirst(vm.status.current.index+1)), id: \.offset) { index, segment in
						HStack {
							Text(segment.label ?? segment.type.rawValue.capitalized)
								.font(.caption2)
							Spacer()
							Text(timeString(segment.seconds))
								.font(.caption2)
								.foregroundColor(.secondary)
						}
						.padding(.vertical, 3)
						.padding(.horizontal, 6)
						.background(segmentColor(for: segment.type))
						.cornerRadius(6)
					}
				}
			}
			.frame(maxHeight: 80)
		}
		.padding(.vertical, 8)
		.padding(.horizontal, 8)
		.background(Color.gray.opacity(0.15))
		.cornerRadius(10)
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
		// Hämta initial status från engine istället för hårdkodade värden
		self.status = engine.getStatus(now: Date().timeIntervalSince1970)
	}
    
    public func start() {
        guard !isRunning else { return }
        // Om engine är pausad, anropa resume istället för start
        if engine.currentState == .paused {
            engine.resume()
        } else {
            engine.start()
        }
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
    
    public func restart() {
        engine.restart()
        isRunning = false
    }

	public func skip() { engine.skip() }
	public func back() { engine.back() }

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
#Preview("Short Workout", traits: .fixedLayout(width: 205, height: 251)) {
    let workout = try! ProgramParser().parse("W6 R3 W6")
    return WatchRunView(workout: workout)
        .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 9 (45mm)"))
}

#Preview("Running Workout", traits: .fixedLayout(width: 205, height: 251)) {
	let workout = try! ProgramParser().parse("W60 R30 W60 R30")
	return WatchRunView(workout: workout)
		.previewDevice(PreviewDevice(rawValue: "Apple Watch Series 9 (45mm)"))
}

#Preview("With Label", traits: .fixedLayout(width: 205, height: 251)) {
	let workout = try! ProgramParser().parse("W30@warmup R60@sprint W30@cooldown")
	return WatchRunView(workout: workout)
		.previewDevice(PreviewDevice(rawValue: "Apple Watch Series 9 (45mm)"))
}

#Preview("Long Intervals", traits: .fixedLayout(width: 176, height: 215)) {
	let workout = try! ProgramParser().parse("W120 R180 W120 R180 W120")
	return WatchRunView(workout: workout)
		.previewDevice(PreviewDevice(rawValue: "Apple Watch SE (40mm)"))
}
#endif

#endif

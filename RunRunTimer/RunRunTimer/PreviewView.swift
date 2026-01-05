import SwiftUI
import RunRunCore

#if os(iOS)

public struct PreviewView: View {
	public let workout: Workout
	public init(workout: Workout) { self.workout = workout }
	public var body: some View {
		List {
			Section("Summering") {
				Text("Tid totalt: \(workout.totals.totalSeconds.timeString)")
				Text("Intervall: \(workout.totals.totalIntervals)")
			}
			Section("Segment") {
				ForEach(workout.segments, id: \.index) { s in
					HStack {
						VStack(alignment: .leading) {
							Text(s.type.rawValue.capitalized)
							if let label = s.label { Text(label).foregroundColor(.secondary) }
						}
						Spacer()
						Text("\(s.seconds)s")
					}
				}
			}
		}
		.navigationTitle("Förhandsvisning")
	}
    
}

#if DEBUG
#Preview {
	NavigationView {
		PreviewView(workout: sampleWorkout)
	}
}

private var sampleWorkout: Workout {
	let parser = ProgramParser()
	return try! parser.parse("P5 (x2 W20@VO2 R10)")
}
#endif
#endif

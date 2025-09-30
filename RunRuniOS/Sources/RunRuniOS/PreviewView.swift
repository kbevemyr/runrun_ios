import SwiftUI
import RunRunCore

#if os(iOS)

public struct PreviewView: View {
	public let workout: Workout
	public init(workout: Workout) { self.workout = workout }
	public var body: some View {
		List {
			Section("Summering") {
				Text("Tid totalt: \(workout.totals.totalSeconds)s")
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
#endif

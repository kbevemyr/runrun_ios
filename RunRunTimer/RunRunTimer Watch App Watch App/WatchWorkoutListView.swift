import SwiftUI
import RunRunCore

#if os(watchOS)

/// Visar en lista över synkade workouts på Apple Watch
public struct WatchWorkoutListView: View {
	@StateObject private var viewModel = WatchWorkoutListViewModel()
	@State private var selectedWorkout: Workout?
	
	public init() {}
	
	public var body: some View {
		NavigationView {
			Group {
				if viewModel.workouts.isEmpty {
					emptyStateView
				} else {
					workoutListView
				}
			}
			.navigationTitle("Workouts")
		}
		.onAppear {
			viewModel.loadWorkouts()
		}
		.sheet(item: $selectedWorkout) { workout in
			WatchRunView(workout: workout)
		}
	}
	
	private var emptyStateView: some View {
		VStack(spacing: 12) {
			Image(systemName: "figure.run.circle")
				.font(.system(size: 40))
				.foregroundColor(.secondary)
			Text("Inga Workouts")
				.font(.headline)
			Text("Skapa i iOS-appen")
				.font(.caption)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
			
			Button("Synka") {
				viewModel.syncWithiPhone()
			}
			.buttonStyle(.bordered)
			.padding(.top, 8)
		}
		.padding()
	}
	
	private var workoutListView: some View {
		List {
			ForEach(viewModel.workouts, id: \.id) { workoutExport in
				Button {
					selectWorkout(workoutExport)
				} label: {
					WatchWorkoutRowView(workout: workoutExport)
				}
				.listRowBackground(Color.clear)
			}
			
			// Synka-knapp längst ner
			Button {
				viewModel.syncWithiPhone()
			} label: {
				Label("Synka med iPhone", systemImage: "arrow.triangle.2.circlepath")
					.font(.caption)
			}
			.listRowBackground(Color.blue.opacity(0.2))
		}
	}
	
	private func selectWorkout(_ export: WorkoutExport) {
		do {
			let workout = try ProgramParser().parse(export.program)
			selectedWorkout = workout
		} catch {
			print("Kunde inte parsa workout: \(error)")
		}
	}
}

// MARK: - Workout Row View

struct WatchWorkoutRowView: View {
	let workout: WorkoutExport
	
	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(workout.title)
				.font(.headline)
				.lineLimit(1)
			
			Text(workout.program)
				.font(.caption2)
				.foregroundColor(.secondary)
				.lineLimit(1)
			
			if let totals = try? ProgramParser().parse(workout.program).totals {
				HStack(spacing: 12) {
					Label("\(totals.totalIntervals)", systemImage: "repeat")
						.font(.caption2)
						.foregroundColor(.secondary)
					
					Label(totals.totalSeconds.timeString, systemImage: "clock")
						.font(.caption2)
						.foregroundColor(.secondary)
				}
			}
		}
		.padding(.vertical, 4)
	}
}

// MARK: - ViewModel

@MainActor
final class WatchWorkoutListViewModel: ObservableObject {
	@Published var workouts: [WorkoutExport] = []
	@Published var isLoading = false
	@Published var errorMessage: String?
	
	private let storage = WorkoutStorage()
	private let connectivity = WatchConnectivityManager.shared
	
	init() {
		// Lyssna på uppdateringar från iPhone
		connectivity.onWorkoutsReceived { [weak self] receivedWorkouts in
			self?.workouts = receivedWorkouts
		}
	}
	
	func loadWorkouts() {
		do {
			workouts = try storage.loadAll()
		} catch {
			errorMessage = "Kunde inte ladda workouts: \(error.localizedDescription)"
		}
	}
	
	func syncWithiPhone() {
		isLoading = true
		connectivity.requestWorkouts()
		
		// Ge det några sekunder att synka
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
			self?.loadWorkouts()
			self?.isLoading = false
		}
	}
}

// MARK: - Identifiable för Workout

extension Workout: Identifiable {
	public var id: String {
		// Skapa ett unikt ID baserat på workout-innehållet
		var hasher = Hasher()
		hasher.combine(segments.count)
		for segment in segments {
			hasher.combine(segment.type.rawValue)
			hasher.combine(segment.seconds)
		}
		return String(hasher.finalize())
	}
}

// MARK: - Preview

#Preview("Tom lista") {
	WatchWorkoutListView()
}

#Preview("Med workouts") {
	PreviewWorkoutListView()
}

// Preview helper view med mock-data
private struct PreviewWorkoutListView: View {
	@StateObject private var viewModel = PreviewWorkoutListViewModel()
	@State private var selectedWorkout: Workout?
	
	var body: some View {
		NavigationView {
			Group {
				if viewModel.workouts.isEmpty {
					VStack(spacing: 12) {
						Image(systemName: "figure.run.circle")
							.font(.system(size: 40))
							.foregroundColor(.secondary)
						Text("Inga Workouts")
							.font(.headline)
						Text("Skapa i iOS-appen")
							.font(.caption)
							.foregroundColor(.secondary)
							.multilineTextAlignment(.center)
					}
					.padding()
				} else {
					List {
						ForEach(viewModel.workouts, id: \.id) { workoutExport in
							Button {
								selectWorkout(workoutExport)
							} label: {
								WatchWorkoutRowView(workout: workoutExport)
							}
							.listRowBackground(Color.clear)
						}
						
						Button {
							// Preview action
						} label: {
							Label("Synka med iPhone", systemImage: "arrow.triangle.2.circlepath")
								.font(.caption)
						}
						.listRowBackground(Color.blue.opacity(0.2))
					}
				}
			}
			.navigationTitle("Workouts")
		}
		.sheet(item: $selectedWorkout) { workout in
			WatchRunView(workout: workout)
		}
	}
	
	private func selectWorkout(_ export: WorkoutExport) {
		do {
			let workout = try ProgramParser().parse(export.program)
			selectedWorkout = workout
		} catch {
			print("Kunde inte parsa workout: \(error)")
		}
	}
}

// Preview ViewModel med mock-data
@MainActor
private final class PreviewWorkoutListViewModel: ObservableObject {
	@Published var workouts: [WorkoutExport] = []
	
	init() {
		// Mock-data för preview
		workouts = [
			WorkoutExport(
				workout: try! ProgramParser().parse("P10 (x5 W30 R30)"),
				title: "HIIT Nybörjare",
				notes: "Perfekt för att komma igång",
				author: "user"
			),
			WorkoutExport(
				workout: try! ProgramParser().parse("P10 (x8 W20 R10)"),
				title: "Tabata",
				notes: "Klassisk Tabata-struktur",
				author: "user"
			),
			WorkoutExport(
				workout: try! ProgramParser().parse("P10 (x4 W3m@VO2 R2m)"),
				title: "VO2 Max Intervals",
				notes: "Tuff träning",
				author: "user"
			)
		]
	}
}

#endif


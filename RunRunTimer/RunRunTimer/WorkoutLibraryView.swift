import SwiftUI
import RunRunCore

#if os(iOS)

public struct WorkoutLibraryView: View {
	@StateObject private var viewModel = WorkoutLibraryViewModel()
	@State private var showingImportError = false
	@State private var importErrorMessage = ""
	
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
			.navigationTitle("My Workouts")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						viewModel.showingImportOptions = true
					} label: {
						Image(systemName: "square.and.arrow.down")
					}
				}
			}
			.confirmationDialog("Import Workout", isPresented: $viewModel.showingImportOptions) {
				Button("Import from Text") {
					viewModel.showingTextImport = true
				}
				Button("Import from File") {
					viewModel.showingFilePicker = true
				}
				Button("Cancel", role: .cancel) {}
			}
			.sheet(isPresented: $viewModel.showingTextImport) {
				TextImportView { program, title in
					viewModel.importFromText(program: program, title: title)
				}
			}
			.fileImporter(
				isPresented: $viewModel.showingFilePicker,
				allowedContentTypes: [.json],
				allowsMultipleSelection: false
			) { result in
				viewModel.handleFileImport(result: result)
			}
			.alert("Import Error", isPresented: $viewModel.showingError) {
				Button("OK", role: .cancel) {}
			} message: {
				Text(viewModel.errorMessage)
			}
		}
		.onAppear {
			viewModel.loadWorkouts()
		}
	}
	
	private var emptyStateView: some View {
		VStack(spacing: 20) {
			Image(systemName: "figure.run.circle")
				.font(.system(size: 80))
				.foregroundColor(.secondary)
			Text("No Saved Workouts")
				.font(.title2)
				.fontWeight(.semibold)
			Text("Create workouts in the Editor and save them here")
				.font(.body)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 40)
		}
		.padding()
	}
	
	private var workoutListView: some View {
		List {
			ForEach(viewModel.workouts, id: \.id) { workout in
				WorkoutRowView(workout: workout) {
					viewModel.loadAndRun(workoutId: workout.id)
				} onShare: {
					viewModel.shareWorkout(id: workout.id)
				} onDelete: {
					viewModel.deleteWorkout(id: workout.id)
				} onEdit: {
					viewModel.startEdit(workoutId: workout.id)
				}
			}
		}
		.sheet(item: $viewModel.selectedWorkout) { workout in
			if let parsedWorkout = viewModel.parsedWorkout {
				NavigationView {
					RunView(workout: parsedWorkout)
						.navigationBarItems(trailing: Button("Done") {
							viewModel.selectedWorkout = nil
						})
				}
			}
		}
		.sheet(isPresented: $viewModel.showingShareSheet) {
			if let url = viewModel.shareURL {
				ShareSheet(items: [url])
			}
		}
		.sheet(isPresented: $viewModel.showingEditor) {
			if let editing = viewModel.editingWorkout {
				NavigationView {
					EditorView(program: editing.program, onProgramUpdated: { newProgram in
						viewModel.applyEdit(newProgram: newProgram)
					})
					.navigationBarItems(leading: Button("Cancel") {
						viewModel.cancelEdit()
					})
				}
			}
		}
	}
}

// MARK: - Workout Row View

struct WorkoutRowView: View {
	let workout: WorkoutExport
	let onRun: () -> Void
	let onShare: () -> Void
	let onDelete: () -> Void
	let onEdit: () -> Void
	
	@State private var showingDetails = false
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text(workout.title)
						.font(.headline)
					Text(workout.program)
						.font(.caption)
						.foregroundColor(.secondary)
						.lineLimit(1)
					if !workout.notes.isEmpty {
						Text(workout.notes)
							.font(.caption)
							.foregroundColor(.secondary)
							.lineLimit(2)
					}
				}
				Spacer()
				Button(action: onRun) {
					Image(systemName: "play.circle.fill")
						.font(.title2)
						.foregroundColor(.blue)
				}
			}
			
			HStack {
				if let totals = try? ProgramParser().parse(workout.program).totals {
					Label("\(totals.totalIntervals) intervals", systemImage: "repeat")
						.font(.caption)
						.foregroundColor(.secondary)
					Spacer()
					Label(timeString(totals.totalSeconds), systemImage: "clock")
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
			
			HStack(spacing: 20) {
				Button(action: { showingDetails.toggle() }) {
					Image(systemName: "info.circle")
						.imageScale(.medium)
				}
				.accessibilityLabel("Details")
				
				Button(action: onShare) {
					Image(systemName: "square.and.arrow.up")
						.imageScale(.medium)
				}
				.accessibilityLabel("Share")
				
				Spacer()
				
				Button(role: .destructive, action: onDelete) {
					Image(systemName: "trash")
						.imageScale(.medium)
				}
				.accessibilityLabel("Delete")
				
				Button(action: onEdit) {
					Image(systemName: "pencil")
						.imageScale(.medium)
				}
				.accessibilityLabel("Edit")
			}
			.buttonStyle(.plain)
			.foregroundColor(.secondary)
			
			if showingDetails {
				VStack(alignment: .leading, spacing: 4) {
					Divider()
					Text("Created: \(formattedDate(workout.createdAt))")
						.font(.caption2)
						.foregroundColor(.secondary)
					Text("Author: \(workout.author)")
						.font(.caption2)
						.foregroundColor(.secondary)
					Text("ID: \(workout.id)")
						.font(.caption2)
						.foregroundColor(.secondary)
				}
				.padding(.top, 4)
			}
		}
		.padding(.vertical, 8)
		.swipeActions(edge: .trailing, allowsFullSwipe: true) {
			Button(role: .destructive, action: onDelete) {
				Label("Delete", systemImage: "trash")
			}
			Button(action: onEdit) {
				Label("Edit", systemImage: "pencil")
			}
		}
		.swipeActions(edge: .leading) {
			Button(action: onShare) {
				Label("Share", systemImage: "square.and.arrow.up")
			}
			Button(action: { showingDetails.toggle() }) {
				Label("Details", systemImage: "info.circle")
			}
		}
	}
	
	private func timeString(_ seconds: Int) -> String {
		let m = seconds / 60
		let s = seconds % 60
		return String(format: "%dm %ds", m, s)
	}
	
	private func formattedDate(_ isoString: String) -> String {
		guard let date = ISO8601DateFormatter().date(from: isoString) else {
			return isoString
		}
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter.string(from: date)
	}
}

// MARK: - Text Import View

struct TextImportView: View {
	@Environment(\.dismiss) var dismiss
	@State private var programText = ""
	@State private var title = ""
	@State private var isValid = false
	@State private var errorMessage = ""
	
	let onImport: (String, String) -> Void
	
	var body: some View {
		NavigationView {
			Form {
				Section("Workout Title") {
					TextField("Enter title", text: $title)
				}
				
				Section("Program") {
					TextEditor(text: $programText)
						.frame(minHeight: 100)
						.font(.system(.body, design: .monospaced))
						.onChange(of: programText) { _, newValue in
							validateProgram(newValue)
						}
				}
				
				Section {
					if !errorMessage.isEmpty {
						Text(errorMessage)
							.foregroundColor(.red)
							.font(.caption)
					} else if !programText.isEmpty {
						Text("✓ Valid program")
							.foregroundColor(.green)
							.font(.caption)
					}
				}
			}
			.navigationTitle("Import from Text")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Import") {
						onImport(programText, title.isEmpty ? "Untitled" : title)
						dismiss()
					}
					.disabled(!isValid || title.isEmpty)
				}
			}
		}
	}
	
	private func validateProgram(_ program: String) {
		let manager = ImportExportManager()
		let result = manager.validateProgram(program)
		isValid = result.isValid
		errorMessage = result.error ?? ""
	}
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
	let items: [Any]
	
	func makeUIViewController(context: Context) -> UIActivityViewController {
		UIActivityViewController(activityItems: items, applicationActivities: nil)
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - ViewModel

@MainActor
final class WorkoutLibraryViewModel: ObservableObject {
	@Published var workouts: [WorkoutExport] = []
	@Published var selectedWorkout: WorkoutExport?
	@Published var parsedWorkout: Workout?
	@Published var showingShareSheet = false
	@Published var shareURL: URL?
	@Published var showingImportOptions = false
	@Published var showingTextImport = false
	@Published var showingFilePicker = false
	@Published var showingError = false
	@Published var errorMessage = ""
	@Published var showingEditor = false
	@Published var editingWorkout: WorkoutExport?
	
	private let storage = WorkoutStorage()
	
	func loadWorkouts() {
		do {
			workouts = try storage.loadAll()
		} catch {
			errorMessage = "Failed to load workouts: \(error.localizedDescription)"
			showingError = true
		}
	}
	
	func loadAndRun(workoutId: String) {
		do {
			guard let (workout, metadata) = try storage.load(id: workoutId) else {
				return
			}
			parsedWorkout = workout
			selectedWorkout = metadata
		} catch {
			errorMessage = "Failed to load workout: \(error.localizedDescription)"
			showingError = true
		}
	}
	
	func shareWorkout(id: String) {
		do {
			let url = try storage.exportToFile(id: id)
			shareURL = url
			showingShareSheet = true
		} catch {
			errorMessage = "Failed to export workout: \(error.localizedDescription)"
			showingError = true
		}
	}

	func startEdit(workoutId: String) {
		do {
			let all = try storage.loadAll()
			guard let export = all.first(where: { $0.id == workoutId }) else { return }
			editingWorkout = export
			showingEditor = true
		} catch {
			errorMessage = "Failed to start edit: \(error.localizedDescription)"
			showingError = true
		}
	}

	func applyEdit(newProgram: String) {
		guard let editing = editingWorkout else { return }
		do {
			let workout = try ProgramParser().parse(newProgram)
			try storage.save(workout: workout, title: editing.title, notes: editing.notes, author: editing.author)
			loadWorkouts()
			showingEditor = false
			editingWorkout = nil
		} catch {
			errorMessage = "Failed to apply edit: \(error.localizedDescription)"
			showingError = true
		}
	}

	func cancelEdit() {
		showingEditor = false
		editingWorkout = nil
	}
	
	func deleteWorkout(id: String) {
		do {
			try storage.delete(id: id)
			loadWorkouts()
		} catch {
			errorMessage = "Failed to delete workout: \(error.localizedDescription)"
			showingError = true
		}
	}
	
	func importFromText(program: String, title: String) {
		do {
			let workout = try ProgramParser().parse(program)
			try storage.save(workout: workout, title: title, notes: "", author: "user")
			loadWorkouts()
		} catch {
			errorMessage = "Failed to import: \(error.localizedDescription)"
			showingError = true
		}
	}
	
	func handleFileImport(result: Result<[URL], Error>) {
		do {
			let urls = try result.get()
			guard let url = urls.first else { return }
			
			// Starta säker åtkomst till filen
			guard url.startAccessingSecurityScopedResource() else {
				errorMessage = "Could not access file"
				showingError = true
				return
			}
			defer { url.stopAccessingSecurityScopedResource() }
			
			_ = try storage.importFromFile(url)
			loadWorkouts()
		} catch {
			errorMessage = "Failed to import file: \(error.localizedDescription)"
			showingError = true
		}
	}
}

#if DEBUG
#Preview {
	WorkoutLibraryView()
}
#endif

#endif


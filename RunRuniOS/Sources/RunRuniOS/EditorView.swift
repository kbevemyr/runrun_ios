import SwiftUI
import RunRunCore

#if os(iOS)

public struct EditorView: View {
	@State private var programText: String
	@State private var validationMessage: String = ""
	@State private var previewWorkout: Workout?
	@State private var debounceTask: Task<Void, Never>?
	@State private var showingSaveDialog = false
	@State private var saveTitle = ""
	@State private var saveNotes = ""
	private let manager = ImportExportManager()
	private let storage = WorkoutStorage()
	private let onProgramUpdated: ((String) -> Void)?

	public init(program: String = "W30 R10", onProgramUpdated: ((String) -> Void)? = nil) {
		self._programText = State(initialValue: program)
		self.onProgramUpdated = onProgramUpdated
	}

	public var body: some View {
		NavigationView {
			VStack(spacing: 8) {
				// Editor Panel - mindre plats
				VStack(spacing: 8) {
				TextEditor(text: $programText)
					.font(.system(.body, design: .monospaced))
					.frame(minHeight: 100)
					.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled(true)
					.keyboardType(.asciiCapable)
					.onChange(of: programText) { _, _ in
						debouncedPreview()
					}

				HStack {
					Button("Validera") { validate() }
					Button("Förhandsvisa") { preview() }
					Button {
						showingSaveDialog = true
					} label: {
						Label("Save", systemImage: "square.and.arrow.down")
					}
					.buttonStyle(.borderedProminent)
					.disabled(previewWorkout == nil)
					
					if onProgramUpdated != nil {
						Button("Apply") { saveProgram() }
					}
				}

					if !validationMessage.isEmpty {
						Text(validationMessage).font(.footnote).foregroundColor(.secondary)
					}
				}
				.padding(.horizontal)
				.padding(.top)

				// Preview Panel - mer plats
				if let workout = previewWorkout {
					ListPreview(workout: workout)
						.padding(.horizontal)
				} else {
					VStack {
						Text("Tryck 'Förhandsvisa' för att se workout")
							.font(.subheadline)
							.foregroundColor(.secondary)
						Spacer()
					}
					.padding()
				}
			}
			.navigationTitle("Editor")
			.sheet(isPresented: $showingSaveDialog) {
				SaveWorkoutDialog(
					programText: programText,
					initialTitle: saveTitle,
					initialNotes: saveNotes
				) { title, notes in
					saveToLibrary(title: title, notes: notes)
				}
			}
		}
	}

	private func validate() {
		let result = manager.validateProgram(programText)
		validationMessage = result.isValid ? "OK" : (result.error ?? "Fel")
	}
	private func preview() {
		do {
			previewWorkout = try manager.importFromText(programText)
			validationMessage = "OK"
		} catch {
			validationMessage = error.localizedDescription
		}
	}
	
	private func saveProgram() {
		// Validera först
		let result = manager.validateProgram(programText)
		if result.isValid {
			onProgramUpdated?(programText)
			validationMessage = "Sparat!"
		} else {
			validationMessage = result.error ?? "Fel vid validering"
		}
	}
	
	private func saveToLibrary(title: String, notes: String) {
		guard let workout = previewWorkout else { return }
		
		do {
			try storage.save(workout: workout, title: title, notes: notes, author: "user")
			validationMessage = "Saved to library!"
			saveTitle = title
			saveNotes = notes
		} catch {
			validationMessage = "Error saving: \(error.localizedDescription)"
		}
	}
	
	private func debouncedPreview() {
		// Avbryt tidigare task
		debounceTask?.cancel()
		
		// Skapa ny task med delay
		debounceTask = Task {
			try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sekunder
			
			// Kontrollera att task inte är avbruten
			guard !Task.isCancelled else { return }
			
			// Kör preview på main thread
			await MainActor.run {
				preview()
			}
		}
	}
}

// MARK: - Save Workout Dialog

struct SaveWorkoutDialog: View {
	@Environment(\.dismiss) var dismiss
	@State private var title: String
	@State private var notes: String
	let programText: String
	let onSave: (String, String) -> Void
	
	init(programText: String, initialTitle: String, initialNotes: String, onSave: @escaping (String, String) -> Void) {
		self.programText = programText
		self._title = State(initialValue: initialTitle)
		self._notes = State(initialValue: initialNotes)
		self.onSave = onSave
	}
	
	var body: some View {
		NavigationView {
			Form {
				Section("Workout Title") {
					TextField("Enter title", text: $title)
				}
				
				Section("Notes (optional)") {
					TextEditor(text: $notes)
						.frame(minHeight: 80)
				}
				
				Section("Program") {
					Text(programText)
						.font(.system(.body, design: .monospaced))
						.foregroundColor(.secondary)
				}
			}
			.navigationTitle("Save Workout")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						onSave(title, notes)
						dismiss()
					}
					.disabled(title.isEmpty)
				}
			}
		}
	}
}

struct ListPreview: View {
	let workout: Workout
	
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
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Totalt: \(workout.totals.totalSeconds)s, Intervall: \(workout.totals.totalIntervals)")
				.font(.headline)
				.padding(.bottom, 4)
			
			ScrollView {
				LazyVStack(spacing: 6) {
					ForEach(workout.segments, id: \.index) { s in
						HStack {
							// Kolumn 1: Type
							Text(s.type.rawValue.capitalized)
								.font(.body)
								.foregroundColor(segmentColor(for: s.type))
								.frame(width: 80, alignment: .leading)
							
							// Kolumn 2: Label
							if let label = s.label {
								Text("@\(label)")
									.foregroundColor(.secondary)
									.font(.caption)
									.padding(.horizontal, 6)
									.padding(.vertical, 2)
									.background(Color.secondary.opacity(0.1))
									.cornerRadius(4)
							} else {
								Text("")
									.frame(height: 20) // Behåller samma höjd som label
							}
							
							Spacer()
							
							// Kolumn 3: Time (sista kolumnen)
							Text("\(s.seconds)s")
								.font(.body)
								.monospacedDigit()
								.frame(width: 50, alignment: .trailing)
						}
						.padding(.horizontal, 12)
						.padding(.vertical, 8)
						.background(Color.gray.opacity(0.05))
						.cornerRadius(8)
						.accessibilityLabel("\(s.type.rawValue) \(s.seconds) sekunder\(s.label.map { " \($0)" } ?? "")")
					}
				}
				.padding(.horizontal, 4)
			}
			.frame(maxHeight: .infinity)
		}
	}
}

#if DEBUG
#Preview {
    NavigationView {
        EditorView(program: "P10 (x3 W60 R20)")
        // "P10 (x3 (x3 W60 R20 W40 R20 W20) R120@restset)"
    }
}

#endif
#endif

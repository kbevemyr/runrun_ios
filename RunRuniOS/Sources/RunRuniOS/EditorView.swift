import SwiftUI
import RunRunCore

#if os(iOS)

public struct EditorView: View {
	@State private var programText: String
	@State private var validationMessage: String = ""
	@State private var previewWorkout: Workout?
	@State private var debounceTask: Task<Void, Never>?
	private let manager = ImportExportManager()
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
						if onProgramUpdated != nil {
							Button("Spara") { saveProgram() }
								.buttonStyle(.borderedProminent)
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

struct ListPreview: View {
	let workout: Workout
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
								.foregroundColor(s.type == .work ? .primary : .secondary)
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

#endif

import SwiftUI
import RunRunCore

#if os(iOS)

// MARK: - ViewModel

@Observable
class EditorViewModel {
    var programText: String
    var title: String
    var notes: String
    var validationMessage: String = ""
    var previewWorkout: Workout?
    var isValidating: Bool = false
    var isNewWorkout: Bool
    
    private let manager: ImportExportManager
    private let storage: WorkoutStorage
    private var debounceTask: Task<Void, Never>?
    
    init(
        program: String = "",
        title: String = "",
        notes: String = "",
        isNewWorkout: Bool = true,
        manager: ImportExportManager = ImportExportManager(),
        storage: WorkoutStorage = WorkoutStorage()
    ) {
        self.programText = program
        self.title = title
        self.notes = notes
        self.isNewWorkout = isNewWorkout
        self.manager = manager
        self.storage = storage
        
        // Initial validation
        Task { @MainActor in
            await validate()
        }
    }
    
    @MainActor
    func updateProgram(_ newText: String) {
        programText = newText
        debouncedPreview()
    }
    
    func debouncedPreview() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await validate()
        }
    }
    
    @MainActor
    func validate() async {
        isValidating = true
        defer { isValidating = false }
        
        // Om texten är tom, visa inget felmeddelande
        let trimmed = programText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            previewWorkout = nil
            validationMessage = ""
            return
        }
        
        do {
            previewWorkout = try manager.importFromText(programText)
            validationMessage = "✓ Valid workout"
        } catch {
            previewWorkout = nil
            validationMessage = userFriendlyError(error)
        }
    }
    
    func saveToLibrary() throws {
        guard let workout = previewWorkout else {
            throw EditorError.noValidWorkout
        }
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw EditorError.emptyTitle
        }
        try storage.save(workout: workout, title: title, notes: notes, author: "user")
        validationMessage = "✓ Saved to library"
        isNewWorkout = false
    }
    
    private func userFriendlyError(_ error: Error) -> String {
        let message = error.localizedDescription
        
        if message.contains("syntax") || message.contains("parse") {
            return "⚠️ Syntax error. Example: P10 (x3 W45@work R15@rest)"
        } else if message.contains("duration") || message.contains("number") {
            return "⚠️ Invalid duration. Use numbers only (e.g., W30, R15)"
        } else if message.isEmpty {
            return "⚠️ Invalid format"
        } else {
            return "⚠️ \(message)"
        }
    }
}

enum EditorError: LocalizedError {
    case noValidWorkout
    case emptyTitle
    
    var errorDescription: String? {
        switch self {
        case .noValidWorkout:
            return "No valid workout to save"
        case .emptyTitle:
            return "Title cannot be empty"
        }
    }
}

// MARK: - Main Editor View

public struct EditorView: View {
    @State private var viewModel: EditorViewModel
    @State private var textEditHistory: [String] = []
    @State private var historyIndex: Int = -1
    @Environment(\.dismiss) var dismiss
    private let onProgramUpdated: ((String) -> Void)?
    private let onWorkoutSaved: (() -> Void)?
    private let isTabMode: Bool
    
    /// Skapar en EditorView med ett program
    public init(program: String = "", isTabMode: Bool = false, onProgramUpdated: ((String) -> Void)? = nil, onWorkoutSaved: (() -> Void)? = nil) {
        self._viewModel = State(initialValue: EditorViewModel(program: program, isNewWorkout: true))
        self.isTabMode = isTabMode
        self.onProgramUpdated = onProgramUpdated
        self.onWorkoutSaved = onWorkoutSaved
    }
    
    /// Skapar en EditorView för att redigera en sparad workout
    public init(savedWorkout: SavedWorkout, isTabMode: Bool = false, onProgramUpdated: ((String) -> Void)? = nil, onWorkoutSaved: (() -> Void)? = nil) {
        self._viewModel = State(initialValue: EditorViewModel(program: savedWorkout.program, title: savedWorkout.title, notes: savedWorkout.notes, isNewWorkout: false))
        self.isTabMode = isTabMode
        self.onProgramUpdated = onProgramUpdated
        self.onWorkoutSaved = onWorkoutSaved
    }
    
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Editor Section
                VStack(spacing: 12) {
                    // Title and Notes Fields
                    VStack(spacing: 8) {
                        TextField("Workout Title", text: $viewModel.title)
                            .font(.headline)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                            .font(.subheadline)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                    }
                    
                    // Quick Insert Toolbar
                    QuickInsertToolbar { template in
                        insertTemplate(template)
                    }
                    
                    // Text Editor with Placeholder
                    ZStack(alignment: .topLeading) {
                        if viewModel.programText.isEmpty {
                            Text("Example: P10 (x3 W45@work R15@rest)")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                        
                        TextEditor(text: Binding(
                            get: { viewModel.programText },
                            set: { newValue in
                                addToHistory(viewModel.programText)
                                viewModel.updateProgram(newValue)
                            }
                        ))
                        .font(.system(.body, design: .monospaced))
                        .frame(height: 120)
                        .scrollContentBackground(.hidden)
                        .background(Color(.systemBackground))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.asciiCapable)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor, lineWidth: 1.5)
                    )
                    
                    // Validation Status
                    HStack(spacing: 12) {
                        if !viewModel.validationMessage.isEmpty {
                            Label(viewModel.validationMessage, systemImage: validationIcon)
                                .font(.caption)
                                .foregroundColor(validationColor)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                Divider()
                
                // Preview Section
                if let workout = viewModel.previewWorkout {
                    WorkoutPreview(workout: workout)
                } else {
                    ContentUnavailableView(
                        "No Preview Available",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Start typing to see your workout preview")
                    )
                }
            }
            .navigationTitle("Workout Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        handleCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveAndDismiss()
                    }
                    .disabled(viewModel.previewWorkout == nil || viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var borderColor: Color {
        if viewModel.validationMessage.contains("✓") {
            return Color.green.opacity(0.5)
        } else if viewModel.validationMessage.contains("⚠️") {
            return Color.red.opacity(0.5)
        } else {
            return Color.secondary.opacity(0.3)
        }
    }
    
    private var validationIcon: String {
        viewModel.validationMessage.contains("✓") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }
    
    private var validationColor: Color {
        viewModel.validationMessage.contains("✓") ? .green : .orange
    }
    
    // MARK: - Actions
    
    private func addToHistory(_ text: String) {
        // Only add if different from current
        if textEditHistory.isEmpty || textEditHistory.last != text {
            // If we're not at the end, remove future history
            if historyIndex < textEditHistory.count - 1 {
                textEditHistory.removeLast(textEditHistory.count - historyIndex - 1)
            }
            textEditHistory.append(text)
            historyIndex = textEditHistory.count - 1
            
            // Limit history to 50 items
            if textEditHistory.count > 50 {
                textEditHistory.removeFirst()
                historyIndex -= 1
            }
        }
    }
    
    private func insertTemplate(_ template: String) {
        addToHistory(viewModel.programText)
        
        let newText: String
        if viewModel.programText.isEmpty {
            newText = template
        } else {
            newText = viewModel.programText + " " + template
        }
        
        // Säkerställ att uppdateringen sker på huvudtråden
        Task { @MainActor in
            viewModel.updateProgram(newText)
        }
    }
    
    private func handleCancel() {
        if isTabMode {
            // Om editorn är en tab, rensa innehållet istället för att stänga
            clearEditor()
        } else {
            // Om editorn är en sheet, stäng den
            dismiss()
        }
    }
    
    private func clearEditor() {
        // Rensa allt innehåll när editorn är en tab
        viewModel = EditorViewModel(program: "", isNewWorkout: true)
        textEditHistory = []
        historyIndex = -1
    }
    
    private func saveAndDismiss() {
        do {
            try viewModel.saveToLibrary()
            onWorkoutSaved?()
            if isTabMode {
                // Om editorn är en tab, rensa innehållet efter sparning
                clearEditor()
            } else {
                // Om editorn är en sheet, stäng den
                dismiss()
            }
        } catch {
            viewModel.validationMessage = "⚠️ Error saving: \(error.localizedDescription)"
        }
    }
}

// MARK: - Quick Insert Toolbar

struct QuickInsertToolbar: View {
    let onInsert: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Menu {
                    Button("Tabata (20s/10s × 8)") {
                        onInsert("P10 (x8 W20@work R10@rest)")
                    }
                    Button("EMOM × 10") {
                        onInsert("P10 (x10 W50@work R10@rest)")
                    }
                    Button("Pyramid") {
                        onInsert("P10 (W20 R10 W30 R10 W40 R10 W30 R10 W20)")
                    }
                    Button("45/15 × 8") {
                        onInsert("P10 (x8 W45@work R15@rest)")
                    }
                    Button("60/30 × 8") {
                        onInsert("P10 (x8 W60@work R30@rest)")
                    }
                } label: {
                    Label("Interval", systemImage: "repeat")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(8)
                }
                
                QuickInsertButton(title: "Prepare", icon: "figure.run") {
                    onInsert("P10")
                }
                
                QuickInsertButton(title: "Work", icon: "flame.fill") {
                    onInsert("W30@work")
                }
                
                QuickInsertButton(title: "Rest", icon: "pause.fill") {
                    onInsert("R15@rest")
                }
                
            }
            .padding(.horizontal, 4)
        }
    }
}

struct QuickInsertButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.12))
                .foregroundColor(.primary)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Workout Preview

struct WorkoutPreview: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Stats Header
            HStack(spacing: 16) {
                StatBadge(
                    icon: "clock.fill",
                    value: workout.totals.totalSeconds.timeString,
                    label: "Total Time"
                )
                StatBadge(
                    icon: "repeat.circle.fill",
                    value: "\(workout.totals.totalIntervals)",
                    label: "Intervals"
                )
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
            
            // Segment List
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(workout.segments, id: \.index) { segment in
                        SegmentRow(segment: segment)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.title3.bold())
            }
            .foregroundColor(.accentColor)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct SegmentRow: View {
    let segment: Segment
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator bar
            RoundedRectangle(cornerRadius: 2)
                .fill(segmentColor)
                .frame(width: 4, height: 32)
            VStack(alignment: .leading) {
                Text(segment.type.rawValue.capitalized)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                if let label = segment.label { Text(label).foregroundColor(.secondary) }
            }
            
            Spacer()
            
            // Duration
            Text(segment.seconds.formatDuration)
                .font(.body.monospacedDigit())
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    private var segmentColor: Color {
        switch segment.type {
        case .work: return Color("WorkColor")
        case .prepare: return Color("PrepareColor")
        case .rest: return Color("RestColor")
        }
    }
    
    
    private var accessibilityDescription: String {
        var desc = "\(segment.type.rawValue) segment, \(segment.seconds.formatDuration)"
        if let label = segment.label {
            desc += ", labeled as \(label)"
        }
        return desc
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    EditorView(program: "P10 (x3 W60@work R20@rest)")
}

#Preview("Complex Workout") {
    EditorView(program: "P10 (x3 (W60 R20 W40 R20 W20) R120@restset)")
}

#Preview("Add new") {
    EditorView()
}
#endif
#endif

import SwiftUI
import RunRunCore

#if os(iOS)

// MARK: - ViewModel

@Observable
class EditorViewModel {
    var programText: String
    var validationMessage: String = ""
    var previewWorkout: Workout?
    var isValidating: Bool = false
    
    private let manager: ImportExportManager
    private let storage: WorkoutStorage
    private var debounceTask: Task<Void, Never>?
    
    init(
        program: String = "W30 R10",
        manager: ImportExportManager = ImportExportManager(),
        storage: WorkoutStorage = WorkoutStorage()
    ) {
        self.programText = program
        self.manager = manager
        self.storage = storage
        
        // Initial validation
        Task { @MainActor in
            await validate()
        }
    }
    
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
        
        do {
            previewWorkout = try manager.importFromText(programText)
            validationMessage = "✓ Valid workout"
        } catch {
            previewWorkout = nil
            validationMessage = userFriendlyError(error)
        }
    }
    
    func saveToLibrary(title: String, notes: String) throws {
        guard let workout = previewWorkout else {
            throw EditorError.noValidWorkout
        }
        try storage.save(workout: workout, title: title, notes: notes, author: "user")
        validationMessage = "✓ Saved to library"
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
    
    var errorDescription: String? {
        switch self {
        case .noValidWorkout:
            return "No valid workout to save"
        }
    }
}

// MARK: - Main Editor View

public struct EditorView: View {
    @State private var viewModel: EditorViewModel
    @State private var showingSaveDialog = false
    @State private var saveTitle = ""
    @State private var saveNotes = ""
    @State private var textEditHistory: [String] = []
    @State private var historyIndex: Int = -1
    private let onProgramUpdated: ((String) -> Void)?
    
    public init(program: String = "W30 R10", onProgramUpdated: ((String) -> Void)? = nil) {
        self._viewModel = State(initialValue: EditorViewModel(program: program))
        self.onProgramUpdated = onProgramUpdated
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Editor Section
                VStack(spacing: 12) {
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
                    
                    // Validation Status & Actions
                    HStack(spacing: 12) {
                        if !viewModel.validationMessage.isEmpty {
                            Label(viewModel.validationMessage, systemImage: validationIcon)
                                .font(.caption)
                                .foregroundColor(validationColor)
                        }
                        
                        Spacer()
                        
                        if onProgramUpdated != nil {
                            Button("Apply") {
                                applyProgram()
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.previewWorkout == nil)
                        }
                        
                        Button {
                            showingSaveDialog = true
                        } label: {
                            Label("Save", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.previewWorkout == nil)
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
            .sheet(isPresented: $showingSaveDialog) {
                SaveWorkoutDialog(
                    programText: viewModel.programText,
                    initialTitle: saveTitle,
                    initialNotes: saveNotes
                ) { title, notes in
                    saveToLibrary(title: title, notes: notes)
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
        
        if viewModel.programText.isEmpty {
            viewModel.updateProgram(template)
        } else {
            viewModel.updateProgram(viewModel.programText + " " + template)
        }
    }
    
    private func applyProgram() {
        if viewModel.previewWorkout != nil {
            onProgramUpdated?(viewModel.programText)
            viewModel.validationMessage = "✓ Applied"
        }
    }
    
    private func saveToLibrary(title: String, notes: String) {
        do {
            try viewModel.saveToLibrary(title: title, notes: notes)
            saveTitle = title
            saveNotes = notes
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
                QuickInsertButton(title: "Interval", icon: "repeat") {
                    onInsert("(x3 W45@work R15@rest)")
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
                
                Menu {
                    Button("Tabata (20s/10s × 8)") {
                        onInsert("P10 (x8 W20@work R10@rest)")
                    }
                    Button("EMOM × 10") {
                        onInsert("(x10 W50@work R10@rest)")
                    }
                    Button("Pyramid") {
                        onInsert("P10 (W20 R10 W30 R10 W40 R10 W30 R10 W20)")
                    }
                    Button("45/15 × 8") {
                        onInsert("P10 (x8 W45@work R15@rest)")
                    }
                } label: {
                    Label("Templates", systemImage: "doc.on.doc.fill")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(8)
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
                    value: timeString(workout.totals.totalSeconds),
                    label: "Total Time"
                )
                StatBadge(
                    icon: "repeat.circle.fill",
                    value: "\(workout.totals.totalIntervals)",
                    label: "Intervals"
                )
                Spacer()
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
    
    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
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
            
            // Type with icon
            HStack(spacing: 6) {
                Image(systemName: segmentIcon)
                    .font(.caption)
                    .foregroundColor(segmentColor)
                Text(segment.type.rawValue.capitalized)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
            }
            .frame(width: 90, alignment: .leading)
            
            // Label badge
            if let label = segment.label {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(segmentColor.opacity(0.12))
                    .cornerRadius(6)
            }
            
            Spacer()
            
            // Duration
            Text(formatDuration(segment.seconds))
                .font(.body.monospacedDigit())
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Label
            Text(segment.label ?? "default")
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
    
    private var segmentIcon: String {
        switch segment.type {
        case .work: return "flame.fill"
        case .prepare: return "figure.run"
        case .rest: return "pause.fill"
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let m = seconds / 60
            let s = seconds % 60
            return s > 0 ? "\(m)m \(s)s" : "\(m)m"
        }
    }
    
    private var accessibilityDescription: String {
        var desc = "\(segment.type.rawValue) segment, \(formatDuration(segment.seconds))"
        if let label = segment.label {
            desc += ", labeled as \(label)"
        }
        return desc
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

// MARK: - Preview

#if DEBUG
#Preview {
    EditorView(program: "P10 (x3 W60@work R20@rest)")
}

#Preview("Complex Workout") {
    EditorView(program: "P10 (x3 (x3 W60 R20 W40 R20 W20) R120@restset)")
}
#endif
#endif

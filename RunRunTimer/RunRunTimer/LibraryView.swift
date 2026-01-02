import SwiftUI
import RunRunCore

#if os(iOS)

// MARK: - ViewModel

@Observable
class LibraryViewModel {
    var workouts: [SavedWorkout] = []
    var searchText: String = ""
    var filterOption: FilterOption = .all
    var sortOption: SortOption = .dateDesc
    var expandedWorkoutID: String?
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let storage: WorkoutStorage
    private let parser = ProgramParser()
    
    init(storage: WorkoutStorage = WorkoutStorage()) {
        self.storage = storage
    }
    
    var filteredAndSortedWorkouts: [SavedWorkout] {
        var result = workouts
        
        // Filter by search
        if !searchText.isEmpty {
            result = result.filter { workout in
                workout.title.localizedCaseInsensitiveContains(searchText) ||
                workout.notes.localizedCaseInsensitiveContains(searchText) ||
                workout.program.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by duration
        switch filterOption {
        case .all:
            break
        case .short:
            result = result.filter { $0.workout.totals.totalSeconds < 600 } // < 10 min
        case .medium:
            result = result.filter { $0.workout.totals.totalSeconds >= 600 && $0.workout.totals.totalSeconds <= 1800 } // 10-30 min
        case .long:
            result = result.filter { $0.workout.totals.totalSeconds > 1800 } // > 30 min
        }
        
        // Sort
        switch sortOption {
        case .nameAsc:
            result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .nameDesc:
            result.sort { $0.title.localizedCompare($1.title) == .orderedDescending }
        case .dateAsc:
            result.sort { $0.createdAt < $1.createdAt }
        case .dateDesc:
            result.sort { $0.createdAt > $1.createdAt }
        case .durationAsc:
            result.sort { $0.workout.totals.totalSeconds < $1.workout.totals.totalSeconds }
        case .durationDesc:
            result.sort { $0.workout.totals.totalSeconds > $1.workout.totals.totalSeconds }
        }
        
        return result
    }
    
    var totalWorkoutTime: Int {
        workouts.reduce(0) { $0 + $1.workout.totals.totalSeconds }
    }
    
    var totalIntervals: Int {
        workouts.reduce(0) { $0 + $1.workout.totals.totalIntervals }
    }
    
    func loadWorkouts() async {
        await MainActor.run { isLoading = true }
        
        do {
            let exports = try storage.loadAll()
            let converted: [SavedWorkout] = exports.compactMap { export in
                do {
                    let workout = try parser.parse(export.program)
                    let createdAt = ISO8601DateFormatter().date(from: export.createdAt) ?? Date()
                    
                    return SavedWorkout(
                        id: export.id,
                        title: export.title,
                        notes: export.notes,
                        program: export.program,
                        workout: workout,
                        createdAt: createdAt,
                        author: export.author
                    )
                } catch {
                    // Skip workouts that can't be parsed
                    print("Warning: Could not parse workout '\(export.title)': \(error)")
                    return nil
                }
            }
            
            await MainActor.run {
                workouts = converted
                isLoading = false
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load workouts: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func deleteWorkout(_ workout: SavedWorkout) throws {
        try storage.delete(id: workout.id)
        workouts.removeAll { $0.id == workout.id }
    }
    
    func updateWorkout(_ workout: SavedWorkout, newProgram: String) throws {
        let parser = ProgramParser()
        let updatedWorkout = try parser.parse(newProgram)
        try storage.save(workout: updatedWorkout, title: workout.title, notes: workout.notes, author: workout.author)
    }
}

enum FilterOption: String, CaseIterable {
    case all = "All"
    case short = "< 10 min"
    case medium = "10-30 min"
    case long = "> 30 min"
}

enum SortOption: String, CaseIterable {
    case dateDesc = "Newest First"
    case dateAsc = "Oldest First"
    case nameAsc = "Name (A-Z)"
    case nameDesc = "Name (Z-A)"
    case durationAsc = "Shortest First"
    case durationDesc = "Longest First"
}

// MARK: - Main Library View

struct LibraryView: View {
    @State private var viewModel = LibraryViewModel()
    @State private var showingEditor = false
    @State private var editingWorkout: SavedWorkout?
    @State private var workoutToDelete: SavedWorkout?
    @State private var showingDeleteAlert = false
    @State private var selectedWorkout: Workout?
    @State private var showingRunView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading workouts...")
                } else if viewModel.workouts.isEmpty {
                    emptyStateView
                } else {
                    workoutListView
                }
            }
            .navigationTitle("My Workouts")
            .toolbar {
                toolbarContent
            }
            .searchable(text: $viewModel.searchText, prompt: "Search workouts")
            .sheet(isPresented: $showingEditor) {
                EditorView()
            }
            .sheet(item: $editingWorkout) { workout in
                EditorView(program: workout.programText) { newProgram in
                    applyEdit(workout: workout, newProgram: newProgram)
                }
            }
            .fullScreenCover(isPresented: $showingRunView) {
                if let workout = selectedWorkout {
                    NavigationView {
                        RunView(workout: workout)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showingRunView = false
                                        selectedWorkout = nil
                                    }
                                }
                            }
                    }
                }
            }
            .alert("Delete Workout", isPresented: $showingDeleteAlert, presenting: workoutToDelete) { workout in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteWorkout(workout)
                }
            } message: { workout in
                Text("Are you sure you want to delete '\(workout.title)'? This cannot be undone.")
            }
            .task {
                await viewModel.loadWorkouts()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Workouts Yet", systemImage: "figure.run.circle")
        } description: {
            Text("Create your first workout to get started")
        } actions: {
            Button("Create Workout") {
                showingEditor = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var workoutListView: some View {
        List {
            // Stats Summary
            Section {
                statsSection
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // Filter Chips
            Section {
                filterSection
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // Workout Cards
            Section {
                ForEach(viewModel.filteredAndSortedWorkouts) { workout in
                    WorkoutCard(
                        workout: workout,
                        isExpanded: viewModel.expandedWorkoutID == workout.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.expandedWorkoutID = viewModel.expandedWorkoutID == workout.id ? nil : workout.id
                            }
                        },
                        onPlay: { startWorkout(workout) },
                        onEdit: { editingWorkout = workout },
                        onShare: { shareWorkout(workout) },
                        onDelete: { confirmDelete(workout) }
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            confirmDelete(workout)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            shareWorkout(workout)
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                value: "\(viewModel.workouts.count)",
                label: "Workouts",
                icon: "list.bullet.rectangle.fill",
                color: .blue
            )
            
            StatCard(
                value: formatTotalTime(viewModel.totalWorkoutTime),
                label: "Total Time",
                icon: "clock.fill",
                color: .orange
            )
            
            StatCard(
                value: "\(viewModel.totalIntervals)",
                label: "Intervals",
                icon: "repeat.circle.fill",
                color: .green
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    FilterChip(
                        title: option.rawValue,
                        isSelected: viewModel.filterOption == option
                    ) {
                        withAnimation {
                            viewModel.filterOption = option
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Section("Sort By") {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            viewModel.sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                Button("Import Workout", systemImage: "square.and.arrow.down") {
                    // Import action
                }
                
                Button("Export All", systemImage: "square.and.arrow.up") {
                    // Export action
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    // MARK: - Actions
    
    private func startWorkout(_ workout: SavedWorkout) {
        // Ensure workout is set before showing the view
        selectedWorkout = workout.workout
        // Small delay to ensure state is updated
        DispatchQueue.main.async {
            showingRunView = true
        }
    }
    
    private func shareWorkout(_ workout: SavedWorkout) {
        // Share functionality
        print("Sharing workout: \(workout.title)")
    }
    
    private func confirmDelete(_ workout: SavedWorkout) {
        workoutToDelete = workout
        showingDeleteAlert = true
    }
    
    private func deleteWorkout(_ workout: SavedWorkout) {
        do {
            try viewModel.deleteWorkout(workout)
        } catch {
            viewModel.errorMessage = "Failed to delete workout"
        }
    }
    
    private func applyEdit(workout: SavedWorkout, newProgram: String) {
        do {
            try viewModel.updateWorkout(workout, newProgram: newProgram)
            editingWorkout = nil
            Task {
                await viewModel.loadWorkouts()
            }
        } catch {
            viewModel.errorMessage = "Failed to update workout: \(error.localizedDescription)"
        }
    }
    
    private func formatTotalTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Workout Card

struct WorkoutCard: View {
    let workout: SavedWorkout
    let isExpanded: Bool
    let onTap: () -> Void
    let onPlay: () -> Void
    let onEdit: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content - always visible
            mainContent
            
            // Expanded details
            if isExpanded {
                expandedContent
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.title)
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                    
                    // Quick stats
                    HStack(spacing: 16) {
                        Label("\(workout.workout.totals.totalIntervals)", systemImage: "repeat.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Label(formatDuration(workout.workout.totals.totalSeconds), systemImage: "clock.fill")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    
                    // Workout composition bar
                    WorkoutCompositionBar(segments: workout.workout.segments)
                        .padding(.top, 4)
                }
                
                Spacer()
                
                // Play button
                Button(action: onPlay) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "play.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .offset(x: 2) // Optical centering
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            // Action buttons
            HStack(spacing: 24) {
                ActionButton(icon: "pencil", label: "Edit") {
                    onEdit()
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(icon: "calendar", text: formatDate(workout.createdAt))
                
                if !workout.notes.isEmpty {
                    DetailRow(icon: "note.text", text: workout.notes)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        Text("Program")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(workout.programText)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        if m > 0 {
            return s > 0 ? "\(m)m \(s)s" : "\(m)m"
        } else {
            return "\(s)s"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.title3.bold())
            }
            .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
}

struct DetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct WorkoutCompositionBar: View {
    let segments: [Segment]
    
    private var segmentGroups: [(type: SegmentType, count: Int)] {
        var groups: [(SegmentType, Int)] = []
        var currentType: SegmentType?
        var currentCount = 0
        
        for segment in segments {
            if segment.type == currentType {
                currentCount += 1
            } else {
                if let type = currentType {
                    groups.append((type, currentCount))
                }
                currentType = segment.type
                currentCount = 1
            }
        }
        
        if let type = currentType {
            groups.append((type, currentCount))
        }
        
        return groups
    }
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(Array(segmentGroups.enumerated()), id: \.offset) { index, group in
                Rectangle()
                    .fill(colorFor(group.type))
                    .frame(height: 6)
                    .frame(maxWidth: .infinity)
            }
        }
        .cornerRadius(3)
    }
    
    private func colorFor(_ type: SegmentType) -> Color {
        switch type {
        case .prepare: return .blue
        case .work: return .red
        case .rest: return .green
        }
    }
}

// MARK: - Models

struct SavedWorkout: Identifiable {
    let id: String
    let title: String
    let notes: String
    let program: String
    let workout: Workout
    let createdAt: Date
    let author: String
    
    var programText: String {
        return program
    }
}



// MARK: - Preview

#if DEBUG
#Preview {
    LibraryView()
}
#endif
#endif

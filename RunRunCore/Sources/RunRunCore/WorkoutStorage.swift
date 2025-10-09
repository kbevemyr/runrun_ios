import Foundation
import Combine

/// Hanterar lokal lagring av workouts på enheten
public final class WorkoutStorage: ObservableObject {
	@Published public private(set) var workouts: [WorkoutExport] = []
	
	private let userDefaults: UserDefaults
	private let storageKey = "com.runrun.saved_workouts"
	private let importExportManager = ImportExportManager()
	private let shouldSyncWithWatch: Bool
	
	public init(userDefaults: UserDefaults = .standard, syncWithWatch: Bool = true) {
		self.userDefaults = userDefaults
		self.shouldSyncWithWatch = syncWithWatch
		
		// Ladda workouts vid initialisering
		if let loaded = try? loadAll() {
			self.workouts = loaded
		}
		
		// Lyssna på workout-uppdateringar från Watch
		if syncWithWatch {
			WatchConnectivityManager.shared.onWorkoutsReceived { [weak self] receivedWorkouts in
				self?.handleReceivedWorkouts(receivedWorkouts)
			}
		}
	}
	
	// MARK: - Save & Load
	
	/// Sparar ett workout lokalt
	public func save(workout: Workout, title: String, notes: String = "", author: String = "user") throws {
		var allWorkouts = try loadAll()
		let export = WorkoutExport(workout: workout, title: title, notes: notes, author: author)
		
		// Ta bort befintlig workout med samma titel (uppdatera)
		allWorkouts.removeAll { $0.title == title }
		allWorkouts.append(export)
		
		let data = try JSONEncoder().encode(allWorkouts)
		userDefaults.set(data, forKey: storageKey)
		
		// Uppdatera published property
		self.workouts = allWorkouts
		
		// Synka med Watch
		if shouldSyncWithWatch {
			WatchConnectivityManager.shared.syncWorkouts(allWorkouts)
		}
	}
	
	/// Laddar alla sparade workouts
	public func loadAll() throws -> [WorkoutExport] {
		guard let data = userDefaults.data(forKey: storageKey) else {
			return []
		}
		return try JSONDecoder().decode([WorkoutExport].self, from: data)
	}
	
	/// Laddar ett specifikt workout baserat på ID
	public func load(id: String) throws -> (workout: Workout, metadata: WorkoutExport)? {
		let workouts = try loadAll()
		guard let export = workouts.first(where: { $0.id == id }) else {
			return nil
		}
		let workout = try ProgramParser().parse(export.program)
		return (workout: workout, metadata: export)
	}
	
	/// Tar bort ett workout
	public func delete(id: String) throws {
		var allWorkouts = try loadAll()
		allWorkouts.removeAll { $0.id == id }
		let data = try JSONEncoder().encode(allWorkouts)
		userDefaults.set(data, forKey: storageKey)
		
		// Uppdatera published property
		self.workouts = allWorkouts
		
		// Synka med Watch
		if shouldSyncWithWatch {
			WatchConnectivityManager.shared.syncWorkouts(allWorkouts)
		}
	}
	
	// MARK: - Export för delning
	
	/// Exporterar ett workout till JSON-data för delning
	public func exportForSharing(id: String) throws -> Data {
		guard let (workout, metadata) = try load(id: id) else {
			throw WorkoutStorageError.notFound
		}
		return try importExportManager.exportToJSON(
			workout,
			title: metadata.title,
			notes: metadata.notes,
			author: metadata.author
		)
	}
	
	/// Exporterar ett workout till fil-URL för delning
	public func exportToFile(id: String) throws -> URL {
		let data = try exportForSharing(id: id)
		let workouts = try loadAll()
		guard let export = workouts.first(where: { $0.id == id }) else {
			throw WorkoutStorageError.notFound
		}
		
		// Skapa temporär fil
		let fileName = "\(export.title.replacingOccurrences(of: " ", with: "_")).runrun"
		let tempDir = FileManager.default.temporaryDirectory
		let fileURL = tempDir.appendingPathComponent(fileName)
		
		try data.write(to: fileURL)
		return fileURL
	}
	
	// MARK: - Import från delning
	
	/// Importerar ett workout från JSON-data
	public func importFromData(_ data: Data) throws -> String {
		let (workout, metadata) = try importExportManager.importFromJSON(data)
		try save(workout: workout, title: metadata.title, notes: metadata.notes, author: metadata.author)
		return metadata.id
	}
	
	// MARK: - Watch Sync
	
	/// Hämtar workouts från Watch
	public func requestSyncFromWatch() {
		guard shouldSyncWithWatch else { return }
		WatchConnectivityManager.shared.requestWorkouts()
	}
	
	/// Skickar alla workouts till Watch
	public func pushToWatch() {
		guard shouldSyncWithWatch else { return }
		if let allWorkouts = try? loadAll() {
			WatchConnectivityManager.shared.syncWorkouts(allWorkouts)
		}
	}
	
	/// Hanterar workouts mottagna från Watch
	private func handleReceivedWorkouts(_ receivedWorkouts: [WorkoutExport]) {
		do {
			var currentWorkouts = try loadAll()
			var hasChanges = false
			
			// Merge: lägg till nya workouts från Watch
			for received in receivedWorkouts {
				if !currentWorkouts.contains(where: { $0.id == received.id }) {
					currentWorkouts.append(received)
					hasChanges = true
				}
			}
			
			if hasChanges {
				let data = try JSONEncoder().encode(currentWorkouts)
				userDefaults.set(data, forKey: storageKey)
				self.workouts = currentWorkouts
				print("Synkade \(receivedWorkouts.count) workouts från Watch")
			}
		} catch {
			print("Kunde inte hantera mottagna workouts: \(error.localizedDescription)")
		}
	}
	
	/// Importerar ett workout från fil-URL
	public func importFromFile(_ url: URL) throws -> String {
		let data = try Data(contentsOf: url)
		return try importFromData(data)
	}
}

// MARK: - Errors

public enum WorkoutStorageError: LocalizedError {
	case notFound
	case invalidData
	
	public var errorDescription: String? {
		switch self {
		case .notFound:
			return "Workout hittades inte"
		case .invalidData:
			return "Ogiltig data"
		}
	}
}


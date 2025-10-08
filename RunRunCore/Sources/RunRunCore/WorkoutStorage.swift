import Foundation

/// Hanterar lokal lagring av workouts på enheten
public final class WorkoutStorage {
	private let userDefaults: UserDefaults
	private let storageKey = "com.runrun.saved_workouts"
	private let importExportManager = ImportExportManager()
	
	public init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}
	
	// MARK: - Save & Load
	
	/// Sparar ett workout lokalt
	public func save(workout: Workout, title: String, notes: String = "", author: String = "user") throws {
		var workouts = try loadAll()
		let export = WorkoutExport(workout: workout, title: title, notes: notes, author: author)
		
		// Ta bort befintlig workout med samma titel (uppdatera)
		workouts.removeAll { $0.title == title }
		workouts.append(export)
		
		let data = try JSONEncoder().encode(workouts)
		userDefaults.set(data, forKey: storageKey)
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
		var workouts = try loadAll()
		workouts.removeAll { $0.id == id }
		let data = try JSONEncoder().encode(workouts)
		userDefaults.set(data, forKey: storageKey)
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


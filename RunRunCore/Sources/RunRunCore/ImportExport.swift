import Foundation

public struct WorkoutExport: Codable {
	public let version: Int
	public let id: String
	public let title: String
	public let notes: String
	public let program: String
	public let createdAt: String
	public let author: String

	public init(workout: Workout, title: String = "", notes: String = "", author: String = "user") {
		self.version = 1
		self.id = "wtk_\(UUID().uuidString.prefix(6))"
		self.title = title
		self.notes = notes
		self.program = workout.original
		self.createdAt = ISO8601DateFormatter().string(from: Date())
		self.author = author
	}
}

public struct ImportExportManager {
	public init() {}

	public func exportToJSON(_ workout: Workout, title: String = "", notes: String = "", author: String = "user") throws -> Data {
		let export = WorkoutExport(workout: workout, title: title, notes: notes, author: author)
		return try JSONEncoder().encode(export)
	}

	public func exportToText(_ workout: Workout) -> String {
		return workout.original
	}

	public func importFromJSON(_ data: Data) throws -> (workout: Workout, metadata: WorkoutExport) {
		let export = try JSONDecoder().decode(WorkoutExport.self, from: data)
		let workout = try ProgramParser().parse(export.program)
		return (workout: workout, metadata: export)
	}

	public func importFromText(_ text: String) throws -> Workout {
		return try ProgramParser().parse(text)
	}

	public func validateProgram(_ program: String) -> (isValid: Bool, error: String?) {
		do {
			_ = try ProgramParser().parse(program)
			return (isValid: true, error: nil)
		} catch {
			return (isValid: false, error: error.localizedDescription)
		}
	}

	public func previewTotals(_ program: String) throws -> WorkoutTotals {
		let workout = try ProgramParser().parse(program)
		return workout.totals
	}
}

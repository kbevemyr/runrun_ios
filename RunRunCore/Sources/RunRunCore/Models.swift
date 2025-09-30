import Foundation

public enum SegmentType: String, Codable, Sendable {
	case prepare
	case work
	case rest
}

public struct Segment: Codable, Sendable, Hashable {
	public let index: Int
	public let type: SegmentType
	public let seconds: Int
	public let label: String?
}

public struct WorkoutTotals: Codable, Sendable, Hashable {
	public let totalSeconds: Int
	public let totalIntervals: Int
	public let workSeconds: Int
	public let restSeconds: Int
	public let prepareSeconds: Int
	
	public init(segments: [Segment]) {
		self.totalSeconds = segments.reduce(0) { $0 + $1.seconds }
		self.totalIntervals = segments.filter { $0.type == .work }.count
		self.workSeconds = segments.filter { $0.type == .work }.reduce(0) { $0 + $1.seconds }
		self.restSeconds = segments.filter { $0.type == .rest }.reduce(0) { $0 + $1.seconds }
		self.prepareSeconds = segments.filter { $0.type == .prepare }.reduce(0) { $0 + $1.seconds }
	}
}

public struct Workout: Codable, Sendable, Hashable {
	public let original: String
	public let segments: [Segment]
	public let totals: WorkoutTotals
}

public struct Status: Sendable, Hashable {
	public struct Current: Sendable, Hashable {
		public let index: Int
		public let type: SegmentType
		public let label: String?
		public let seconds: Int
		public let elapsed: Int
		public let left: Int
		public init(index: Int, type: SegmentType, label: String?, seconds: Int, elapsed: Int, left: Int) {
			self.index = index
			self.type = type
			self.label = label
			self.seconds = seconds
			self.elapsed = elapsed
			self.left = left
		}
	}
	public struct Progress: Sendable, Hashable {
		public let intervalsDone: Int
		public let intervalsLeft: Int
		public let segmentsDone: Int
		public let segmentsLeft: Int
		public let timeLeft: Int
		public let elapsedTotal: Int
		public init(intervalsDone: Int, intervalsLeft: Int, segmentsDone: Int, segmentsLeft: Int, timeLeft: Int, elapsedTotal: Int) {
			self.intervalsDone = intervalsDone
			self.intervalsLeft = intervalsLeft
			self.segmentsDone = segmentsDone
			self.segmentsLeft = segmentsLeft
			self.timeLeft = timeLeft
			self.elapsedTotal = elapsedTotal
		}
	}
	public struct Next: Sendable, Hashable {
		public let type: SegmentType
		public let label: String?
		public let seconds: Int
		public init(type: SegmentType, label: String?, seconds: Int) {
			self.type = type
			self.label = label
			self.seconds = seconds
		}
	}
	public let current: Current
	public let progress: Progress
	public let next: Next?
	public init(current: Current, progress: Progress, next: Next?) {
		self.current = current
		self.progress = progress
		self.next = next
	}
}

public enum TransitionKind: String, Sendable {
	case prepareToWork
	case workToRest
	case restToWork
	case end
}

public protocol Notifier: Sendable {
	func notifyTransition(_ kind: TransitionKind)
	func notifyPreAlert(secondsBefore: Int)
}

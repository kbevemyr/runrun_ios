import XCTest
@testable import RunRunCore

final class RunRunCoreTests: XCTestCase {
	func testBasicParsing() throws {
		let builder = ProgramParser()
		
		// Test basic segments
		let workout1 = try builder.parse("W30 R10")
		XCTAssertEqual(workout1.segments.count, 1)
		XCTAssertEqual(workout1.segments[0].type, SegmentType.work)
		XCTAssertEqual(workout1.segments[0].seconds, 30)
		XCTAssertEqual(workout1.totals.totalIntervals, 1)
		XCTAssertEqual(workout1.totals.totalSeconds, 30)
	}

	func testDurationParsing() throws {
		let builder = ProgramParser()
		
		// Test different duration formats
		let workout1 = try builder.parse("W1m30s R45")
		XCTAssertEqual(workout1.segments[0].seconds, 90) // 1m30s = 90s
		
		let workout2 = try builder.parse("W2h R1m W2h")
		XCTAssertEqual(workout2.segments[0].seconds, 7200) // 2h = 7200s
		XCTAssertEqual(workout2.segments[1].seconds, 60) // 1m = 60s
		XCTAssertEqual(workout2.segments[2].seconds, 7200) // 2h = 7200s
	}

	func testRepeats() throws {
		let builder = ProgramParser()
		
		let workout = try builder.parse("x3 W30 R10")
		XCTAssertEqual(workout.segments.count, 5) // 3 * (W30 + R10)
		XCTAssertEqual(workout.totals.totalIntervals, 3)
		XCTAssertEqual(workout.totals.totalSeconds, 110) // 3 * 30 + 2 * 10
	}


	func testGroups() throws {
		let builder = ProgramParser()
		
		let workout = try builder.parse("(x2 W30 R10)")
		XCTAssertEqual(workout.segments.count, 3) // 2 * (W30 + R10)
		XCTAssertEqual(workout.totals.totalIntervals, 2)
	}

	func testLabels() throws {
		let builder = ProgramParser()
		
		let workout = try builder.parse("W30@tempo R10@rest")
		XCTAssertEqual(workout.segments[0].label, "tempo")
		XCTAssertEqual(workout.segments[1].label, "rest")
	}

	func testComplexProgram() throws {
		let builder = ProgramParser()
		
		let program = "P10 (x3 (x3 W70@VO2 R20) R2m@set-rest)"
		let workout = try builder.parse(program)
		
		// Should have: P10 + 3 * (3 * (W70 + R20) + R120)
		// = P10 + 3 * (W70 + R20 + W70 + R20 + W70) + R120)
		// = P10 + W70 + R20 + W70 + R20 + W70 + R120 + W70 + R20 + W70 + R20 + W70 + R120 + W70 + R20 + W70 + R20 + W70
		XCTAssertEqual(workout.totals.totalIntervals, 9) // 3 * 3 work segments
		XCTAssertEqual(workout.totals.workSeconds, 9 * 70) // 9 * 70s work
	}

	
	func testRepeatedGroupEndsWithWork() throws {
		let builder = ProgramParser()
		
		// Test that P6 (x2 W2 R1) expands to P6 W2 R1 W2
		let workout = try builder.parse("P6 (x2 W2 R1)")
		
		// Should have 5 segments: P6, W2, R1, W2
		XCTAssertEqual(workout.segments.count, 4)
		XCTAssertEqual(workout.segments[0].type, SegmentType.prepare)
		XCTAssertEqual(workout.segments[1].type, SegmentType.work)
		XCTAssertEqual(workout.segments[2].type, SegmentType.rest)
		XCTAssertEqual(workout.segments[3].type, SegmentType.work)
		
		// Should have 2 intervals (work segments)
		XCTAssertEqual(workout.totals.totalIntervals, 2)
	}
}

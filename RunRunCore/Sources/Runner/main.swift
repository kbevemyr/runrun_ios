import Foundation
import RunRunCore

let args = CommandLine.arguments.dropFirst()
let showAST = args.contains("--ast")
let program: String
if args.isEmpty || (args.count == 1 && args[0] == "--ast") {
    program = "P10 (x3 (x3 W70@VO2 R20) R2m@set-rest)"
} else {
    program = args.filter { $0 != "--ast" }.joined(separator: " ")
}

do {
    let result = try ProgramParser().parseWithAST(program)
    let workout = result.workout
    let ast = result.ast
    
    print("Program:", workout.original)
    print("Segments:", workout.segments.count)
    for (i, s) in workout.segments.enumerated() {
        let label = s.label.map { "@\($0)" } ?? ""
        print("\(i+1). \(s.type) \(s.seconds)s \(label)")
    }
    print("Totals: intervals=\(workout.totals.totalIntervals) work=\(workout.totals.workSeconds)s rest=\(workout.totals.restSeconds)s prepare=\(workout.totals.prepareSeconds)s total=\(workout.totals.totalSeconds)s")

    if showAST {
        print("\nAST (Abstract Syntax Tree):")
        print(ast)
    }

    // Print expanded structure as JSON
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    if let jsonData = try? encoder.encode(workout),
       let json = String(data: jsonData, encoding: .utf8) {
        print("\nExpanded structure (JSON):")
        print(json)
    }
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}



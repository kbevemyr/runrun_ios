import Foundation
import RunRunCore

print("🏃‍♀️ RunRun Core Test")
print("==================")

let builder = ProgramParser()

// Testa olika workout-program
let programs = [
    "W30 R10",
    "x3 W30 R10", 
    "(W30 R10) x2",
    "x2 (W30 R10)",
    "W70@VO2 R20@rest",
    "P10 (x3 (x3 W70@VO2 R20) R2m@set-rest)"
]

for (index, program) in programs.enumerated() {
    print("\n\(index + 1). Program: \(program)")
    
    do {
        let workout = try builder.parse(program)
        print("   ✅ Segments: \(workout.segments.count)")
        print("   ⏱️  Total time: \(workout.totals.totalSeconds)s")
        print("   🔄 Intervals: \(workout.totals.totalIntervals)")
        print("   💪 Work: \(workout.totals.workSeconds)s")
        print("   😴 Rest: \(workout.totals.restSeconds)s")
        
        // Visa första segmentet
        if let first = workout.segments.first {
            print("   📝 First segment: \(first.type) \(first.seconds)s\(first.label != nil ? " @\(first.label!)" : "")")
        }
        
    } catch {
        print("   ❌ Error: \(error)")
    }
}

print("\n🎉 Alla tester klara!")
print("\nFör att köra i iOS Simulator:")
print("1. Öppna Xcode")
print("2. File → New → Project")
print("3. Välj iOS → App")
print("4. Lägg till RunRunCore som dependency")
print("5. Använd RunRuniOS SwiftUI views")

import Foundation
import RunRunCore
import RunRunWatch

#if os(watchOS)
import SwiftUI

@main
struct RunRunWatchTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var workout: Workout?
    
    var body: some View {
        VStack {
            if let workout = workout {
                WatchRunView(workout: workout)
            } else {
                VStack {
                    Text("RunRun Watch")
                        .font(.headline)
                    Button("Testa Timer") {
                        createTestWorkout()
                    }
                }
            }
        }
    }
    
    private func createTestWorkout() {
        do {
            let builder = ProgramParser()
            workout = try builder.parse("W30 R10 W30 R10")
        } catch {
            print("Fel: \(error)")
        }
    }
}
#else
// watchOS test app - kör på Apple Watch simulator eller enhet
#endif

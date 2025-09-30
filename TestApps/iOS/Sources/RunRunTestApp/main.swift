import Foundation
import RunRunCore
import RunRuniOS

#if os(iOS)
import SwiftUI

@main
struct RunRunTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var program = "P10 (x3 (x3 W70@VO2 R20) R2m@set-rest)"
    @State private var workout: Workout?
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("RunRun Test App")
                    .font(.largeTitle)
                    .bold()
                
                TextEditor(text: $program)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                
                Button("Testa Program") {
                    testProgram()
                }
                .buttonStyle(.borderedProminent)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if let workout = workout {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Resultat:")
                            .font(.headline)
                        Text("Totalt: \(workout.totals.totalSeconds)s")
                        Text("Intervall: \(workout.totals.totalIntervals)")
                        Text("Segment: \(workout.segments.count)")
                        
                        NavigationLink("Starta Timer", destination: RunView(workout: workout))
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Test")
        }
    }
    
    private func testProgram() {
        do {
            let builder = ProgramParser()
            workout = try builder.parse(program)
            errorMessage = ""
        } catch {
            errorMessage = "Fel: \(error.localizedDescription)"
            workout = nil
        }
    }
}
#else
// iOS test app - kör på iOS simulator eller enhet
#endif

# RunRun iOS App

En enkel iOS-app som demonstrerar RunRunCore funktionalitet.

## Köra i iOS Simulator

### Metod 1: Xcode (Rekommenderat)

1. **Öppna Xcode**
2. **File → New → Project**
3. **Välj iOS → App**
4. **Konfigurera projektet:**
   - Product Name: `RunRunApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Use Core Data: `Nej`

5. **Lägg till RunRunCore som dependency:**
   - Välj projektet i navigatorn
   - Gå till "Package Dependencies"
   - Klicka "+" och välj "Add Local..."
   - Navigera till `../RunRunCore` och välj den

6. **Ersätt innehållet i ContentView.swift:**
   ```swift
   import SwiftUI
   import RunRunCore
   import RunRuniOS
   
   struct ContentView: View {
       @State private var workoutProgram = "W30 R10"
       @State private var workout: Workout?
       @State private var errorMessage: String?
       
       var body: some View {
           NavigationView {
               VStack(spacing: 20) {
                   Text("🏃‍♀️ RunRun Interval Timer")
                       .font(.largeTitle)
                       .fontWeight(.bold)
                   
                   VStack(alignment: .leading, spacing: 10) {
                       Text("Workout Program:")
                           .font(.headline)
                       
                       TextField("Ange workout program", text: $workoutProgram)
                           .textFieldStyle(RoundedBorderTextFieldStyle())
                           .onChange(of: workoutProgram) { _ in
                               parseWorkout()
                           }
                       
                       Text("Exempel: W30 R10, x3 W30 R10, (W30 R10) x2")
                           .font(.caption)
                           .foregroundColor(.secondary)
                   }
                   .padding()
                   
                   if let error = errorMessage {
                       Text("❌ Error: \(error)")
                           .foregroundColor(.red)
                           .padding()
                   }
                   
                   if let workout = workout {
                       VStack(alignment: .leading, spacing: 8) {
                           Text("📊 Workout Info")
                               .font(.headline)
                           
                           HStack {
                               Text("Segments:")
                               Spacer()
                               Text("\(workout.segments.count)")
                           }
                           
                           HStack {
                               Text("Total tid:")
                               Spacer()
                               Text("\(workout.totals.totalSeconds)s")
                           }
                           
                           HStack {
                               Text("Intervals:")
                               Spacer()
                               Text("\(workout.totals.totalIntervals)")
                           }
                           
                           HStack {
                               Text("Work:")
                               Spacer()
                               Text("\(workout.totals.workSeconds)s")
                           }
                           
                           HStack {
                               Text("Rest:")
                               Spacer()
                               Text("\(workout.totals.restSeconds)s")
                           }
                       }
                       .padding()
                       .background(Color.gray.opacity(0.1))
                       .cornerRadius(10)
                       
                       Button("▶️ Starta Workout") {
                           print("Startar workout: \(workoutProgram)")
                       }
                       .buttonStyle(.borderedProminent)
                       .padding()
                   }
                   
                   Spacer()
               }
               .padding()
               .onAppear {
                   parseWorkout()
               }
           }
       }
       
       private func parseWorkout() {
           let builder = WorkoutBuilder()
           do {
               workout = try builder.build(from: workoutProgram)
               errorMessage = nil
           } catch {
               errorMessage = error.localizedDescription
               workout = nil
           }
       }
   }
   ```

7. **Välj simulator och kör:**
   - Välj en iOS Simulator (t.ex. iPhone 15)
   - Tryck Cmd+R för att köra

### Metod 2: Swift Package Manager (Begränsat)

```bash
cd RunRunApp
swift build
swift run
```

**Obs:** Denna metod kör bara terminal-versionen, inte iOS UI.

## Testa olika workout-program

- `W30 R10` - 30s work, 10s rest
- `x3 W30 R10` - upprepa 3 gånger
- `(W30 R10) x2` - grupp upprepad 2 gånger
- `W70@VO2 R20@rest` - med etiketter
- `P10 (x3 (x3 W70@VO2 R20) R2m@set-rest)` - komplext program

## Nästa steg

För en fullständig app, integrera med:
- `RunRuniOS` SwiftUI views (EditorView, PreviewView, RunView)
- `RunRunWatch` för Apple Watch
- Core Data för sparade workouts
- Notifications för bakgrunds-timer

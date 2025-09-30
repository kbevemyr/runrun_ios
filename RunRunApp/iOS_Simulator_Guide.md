# 🏃‍♀️ RunRun iOS Simulator Guide

## ✅ Terminal-test (Fungerar nu!)

```bash
cd RunRunApp
swift run
```

## 📱 iOS Simulator (Rekommenderat)

### Steg 1: Skapa Xcode-projekt

1. **Öppna Xcode**
2. **File → New → Project**
3. **Välj iOS → App**
4. **Konfigurera:**
   - Product Name: `RunRunApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Use Core Data: `Nej`

### Steg 2: Lägg till RunRunCore

1. **Välj projektet** i navigatorn (blå ikon)
2. **Gå till "Package Dependencies"** (under projektet)
3. **Klicka "+"** → **"Add Local..."**
4. **Navigera till `../RunRunCore`** och välj den
5. **Klicka "Add Package"**

### Steg 3: Skapa ContentView

Ersätt innehållet i `ContentView.swift` med:

```swift
import SwiftUI
import RunRunCore

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

#Preview {
    ContentView()
}
```

### Steg 4: Kör i Simulator

1. **Välj en iOS Simulator** (t.ex. iPhone 15)
2. **Tryck Cmd+R** för att köra
3. **Testa olika workout-program:**
   - `W30 R10` - grundläggande
   - `x3 W30 R10` - upprepningar
   - `(W30 R10) x2` - grupper
   - `W70@VO2` - etiketter

## 🎯 Vad du får

- **Live parsing** av workout-program
- **Visar workout-info** (segments, tid, intervals)
- **Stöder alla syntaxer** från RunRunCore
- **Riktig iOS UI** med SwiftUI

## 🔧 Felsökning

Om du får fel:
1. Kontrollera att RunRunCore är tillagd som dependency
2. Se till att du valt iOS som target (inte macOS)
3. Kontrollera att du använder iOS 13+ som deployment target

## 🚀 Nästa steg

För en fullständig app, integrera med:
- `RunRuniOS` SwiftUI views (EditorView, PreviewView, RunView)
- `RunRunWatch` för Apple Watch
- Core Data för sparade workouts

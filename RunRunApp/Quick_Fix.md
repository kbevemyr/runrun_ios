# 🚀 Snabb Fix för "no such module 'RunRunCore'"

## Problem
Xcode kan inte hitta `RunRunCore` modulen.

## ✅ Snabbaste lösning

### Steg 1: Öppna rätt katalog i Xcode
```bash
cd /Users/katrin/runrun_ios
open .
```

### Steg 2: Skapa nytt Xcode-projekt
1. **File → New → Project**
2. **iOS → App**
3. **Konfigurera:**
   - Product Name: `RunRunApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
4. **Spara i:** `/Users/katrin/runrun_ios/RunRunApp/`

### Steg 3: Lägg till RunRunCore
1. **Välj projektet** (blå ikon)
2. **Package Dependencies** → **"+"**
3. **Add Local...**
4. **Välj:** `../RunRunCore` (relativ sökväg)
5. **Add Package**

### Steg 4: Ersätt ContentView.swift
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

### Steg 5: Kör i Simulator
1. **Välj iPhone Simulator**
2. **Cmd+R**

## 🎯 Varför detta fungerar

- **Relativ sökväg** (`../RunRunCore`) fungerar bättre än absolut
- **Samma katalog** som RunRunCore paketet
- **Rätt iOS target** istället för macOS

## 🔧 Alternativ: Använd Terminal

Om Xcode fortfarande inte fungerar:
```bash
cd /Users/katrin/runrun_ios/RunRunApp
swift run
```

Detta testar alla RunRunCore funktioner i terminalen.

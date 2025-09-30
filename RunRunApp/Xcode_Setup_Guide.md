# 🔧 Xcode Setup Guide för RunRun

## Problem: "no such module 'RunRunCore'"

Detta händer när Xcode inte kan hitta `RunRunCore` paketet. Här är lösningarna:

## ✅ Lösning 1: Använd rätt sökväg

1. **Öppna Xcode-projektet** i `/Users/katrin/Projekts/RunRunApp/`
2. **Välj projektet** (blå ikon) → **Package Dependencies**
3. **Ta bort** befintlig RunRunCore dependency
4. **Klicka "+"** → **"Add Local..."**
5. **Navigera till:** `/Users/katrin/runrun_ios/RunRunCore`
6. **Välj RunRunCore mappen** och klicka **"Add Package"**

## ✅ Lösning 2: Skapa Xcode-projekt i rätt katalog

1. **Stäng** nuvarande Xcode-projekt
2. **Öppna Terminal** och kör:
   ```bash
   cd /Users/katrin/runrun_ios
   open RunRunApp.xcodeproj
   ```
3. Om det inte finns, skapa det:
   ```bash
   cd /Users/katrin/runrun_ios
   xcodebuild -project RunRunApp.xcodeproj -list 2>/dev/null || echo "Skapar Xcode-projekt"
   ```

## ✅ Lösning 3: Använd Swift Package Manager direkt

1. **Öppna Terminal**
2. **Navigera till RunRunApp:**
   ```bash
   cd /Users/katrin/runrun_ios/RunRunApp
   ```
3. **Kör appen:**
   ```bash
   swift run
   ```

## ✅ Lösning 4: Skapa nytt Xcode-projekt

1. **Öppna Xcode**
2. **File → New → Project**
3. **iOS → App** → **Next**
4. **Konfigurera:**
   - Product Name: `RunRunApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
5. **Spara i:** `/Users/katrin/runrun_ios/RunRunApp/`
6. **Lägg till RunRunCore:**
   - Välj projektet → Package Dependencies
   - Klicka "+" → Add Local...
   - Välj `../RunRunCore` (relativ sökväg)
7. **Ersätt ContentView.swift** med koden från guiden

## 🔍 Verifiera att det fungerar

Efter att ha lagt till RunRunCore, kontrollera att:
- ✅ RunRunCore visas i Package Dependencies
- ✅ `import RunRunCore` inte ger fel
- ✅ `WorkoutBuilder()` kan användas
- ✅ Projektet bygger utan fel

## 📱 Testa i Simulator

1. **Välj iPhone Simulator**
2. **Tryck Cmd+R**
3. **Testa workout-program:**
   - `W30 R10`
   - `x3 W30 R10`
   - `(W30 R10) x2`

## 🚨 Vanliga fel

- **"no such module"** → Fel sökväg till RunRunCore
- **"could not build"** → Kontrollera att RunRunCore kompilerar
- **"import error"** → Se till att du valt iOS som target

## 💡 Tips

- Använd **relativa sökvägar** (`../RunRunCore`) istället för absoluta
- Kontrollera att **iOS** är valt som target, inte macOS
- Se till att **deployment target** är iOS 13+

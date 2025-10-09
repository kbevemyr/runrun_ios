# Hur man kör Apple Watch-appen

## Metod 1: Via Xcode (Enklast)

### Steg 1: Öppna projektet
```bash
cd /Users/katrin/runrun_ios/RunRunApp/RunRunApp
open RunRunApp.xcodeproj
```

### Steg 2: Lägg till Watch-appen som target
I Xcode:
1. Klicka på "RunRunApp" i Project Navigator (vänster sidebar)
2. Gå till "File" → "Add Package Dependencies..."
3. Välj "Add Local..." och navigera till `/Users/katrin/runrun_ios/RunRunWatch`
4. Klicka "Add Package"

### Steg 3: Välj Watch Simulator
1. Klicka på scheme-väljaren (bredvid play-knappen, där det står "RunRunApp")
2. Välj en Apple Watch simulator, t.ex:
   - Apple Watch Series 9 (45mm)
   - Apple Watch Ultra 2
   - Apple Watch SE (40mm)

### Steg 4: Kör!
- Tryck **Cmd + R** eller klicka på play-knappen
- Watch-simulatorn öppnas
- Din app startar automatiskt

---

## Metod 2: Kör Watch Test-appen direkt

### Med Xcode:
```bash
cd /Users/katrin/runrun_ios/TestApps/watchOS
open Package.swift
```

Detta öppnar Package i Xcode som ett standalone-projekt.

Sedan:
1. Välj "RunRunWatchTestApp" som target
2. Välj Apple Watch simulator
3. Tryck Cmd + R

### Med terminal + simulator:
```bash
cd /Users/katrin/runrun_ios/TestApps/watchOS

# Bygg för watchOS
swift build --triple arm64-apple-watchos

# Obs: att köra direkt i simulator från terminal är komplicerat
# Rekommenderar Xcode-metoden istället
```

---

## Metod 3: För riktiga enheter

### Förutsättningar:
- Utvecklarcertifikat
- iPhone parad med Apple Watch
- Båda enheterna anslutna till Xcode

### Steg:
1. Anslut iPhone till datorn
2. Öppna Xcode
3. Välj din Apple Watch som destination
4. Klicka "Trust" på båda enheterna
5. Bygg och kör (Cmd + R)

---

## Snabbaste sättet just nu:

### Kör watchOS test-appen:
```bash
# 1. Öppna watchOS test-projektet
cd /Users/katrin/runrun_ios/TestApps/watchOS
open Package.swift

# 2. I Xcode som öppnas:
#    - Välj "My Mac (Designed for iPad)" INTE, välj en Watch simulator
#    - Eller Product → Destination → Apple Watch Series 9
#    - Tryck Cmd + R
```

---

## Troubleshooting

### "No simulator devices are available"
**Lösning:**
```bash
# Öppna Simulator-appen först
open -a Simulator

# Välj en Apple Watch:
# I Simulator-menyn: File → Open Simulator → watchOS → Apple Watch Series 9
```

### "Build target has a minimum deployment target"
**Lösning:** Detta är redan fixat! Om du fortfarande ser detta:
```bash
# Rensa build-mappen
rm -rf ~/Library/Developer/Xcode/DerivedData/RunRunApp-*

# Starta om Xcode
```

### "Module 'RunRunCore' not found"
**Lösning:**
1. Stäng Xcode
2. Ta bort Package cache:
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .build
```
3. Öppna Xcode igen
4. File → Packages → Reset Package Caches

### Watch-appen visar "Inga Workouts"
**Detta är normalt första gången!**

För att få workouts:
1. Kör iOS-appen först
2. Skapa och spara några workouts
3. Starta Watch-appen
4. Tryck "Synka med iPhone"

---

## Rekommenderad arbetsflöde:

### För utveckling:
1. **Kör iOS-appen först:**
   ```bash
   cd RunRunApp/RunRunApp
   open RunRunApp.xcodeproj
   # Välj iPhone simulator, Cmd + R
   ```

2. **Skapa test-workouts:**
   - Gå till Editor-fliken
   - Skapa några workouts, t.ex:
     - "Snabb": `W30 R30 W30`
     - "Lång": `W60 R120 W60 R120`
   - Spara i Library

3. **Kör Watch-appen:**
   ```bash
   cd TestApps/watchOS
   open Package.swift
   # Välj Apple Watch simulator, Cmd + R
   ```

4. **Synka:**
   - Tryck "Synka med iPhone" i Watch-appen
   - Workouts dyker upp!

---

## Pro-tips:

### Kör båda samtidigt:
Du kan ha både iPhone- och Watch-simulatorn igång samtidigt:
1. Starta iOS-appen i iPhone simulator
2. I en annan Xcode-instans (eller samma), starta Watch-appen
3. Båda simulatorerna visas på skärmen
4. Testa synkronisering live!

### Använd Xcode Canvas för snabb iteration:
I WatchWorkoutListView.swift kan du använda SwiftUI previews:
- Öppna filen i Xcode
- Tryck **Option + Cmd + Return** för Canvas
- Se live preview av Watch-UI

### Debug båda samtidigt:
- Sätt breakpoints i både iOS- och Watch-kod
- Kör båda apparna i debug-mode
- Se kommunikationen mellan enheterna

---

**Lycka till!** 🚀⌚️


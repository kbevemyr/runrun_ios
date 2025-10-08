# Fix: Xcode Build Errors

## Problem 1: WorkoutStorage not found in scope
EditorView.swift visar kompileringsfel: "Cannot find 'WorkoutStorage' in scope" på rad 15.

**Status:** ✅ FIXAT - WorkoutExport conformar nu till Identifiable

## Problem 2: WorkoutExport requires Identifiable
WorkoutLibraryView.swift visar: "Instance method 'sheet(item:)' requires that 'WorkoutExport' conform to 'Identifiable'"

**Status:** ✅ FIXAT - WorkoutExport conformar nu till Identifiable

## Orsak
Xcode har inte uppdaterat sina Swift Package Manager-cacher efter att WorkoutStorage.swift lades till.

## Lösningar

### Lösning 1: Rensa Derived Data och Bygg Om (REKOMMENDERAD)

1. Öppna Xcode
2. Stäng projektet om det är öppet
3. Rensa Derived Data:
   - Gå till **Xcode → Settings/Preferences** (Cmd+,)
   - Välj **Locations**-tabben
   - Klicka på pilen bredvid **Derived Data**-sökvägen
   - I Finder som öppnas, hitta mappen för ditt projekt
   - Ta bort hela projektmappen ELLER ta bort allt i Derived Data
4. Öppna projektet igen: `RunRunApp/RunRunApp/RunRunApp.xcodeproj`
5. Uppdatera paket:
   - Gå till **File → Packages → Update to Latest Package Versions**
6. Rensa bygget:
   - **Product → Clean Build Folder** (Shift+Cmd+K)
7. Bygg om:
   - **Product → Build** (Cmd+B)

### Lösning 2: Återställ Package Caches

1. Öppna Xcode
2. Gå till **File → Packages → Reset Package Caches**
3. Vänta tills processen är klar
4. Bygg om: **Product → Build** (Cmd+B)

### Lösning 3: Terminal-kommando (Om Xcode fortfarande krånglar)

```bash
# Gå till projekt-roten
cd /Users/katrin/runrun_ios/RunRunApp/RunRunApp

# Rensa Swift package caches
rm -rf .build
rm -rf ~/Library/Developer/Xcode/DerivedData/*RunRun*

# Öppna projektet
open RunRunApp.xcodeproj

# I Xcode:
# File → Packages → Reset Package Caches
# Product → Clean Build Folder (Shift+Cmd+K)
# Product → Build (Cmd+B)
```

### Lösning 4: Verifiera Package Dependencies

Om ovan inte fungerar, kontrollera att RunRunApp har rätt dependencies:

1. I Xcode, välj projektet i navigator (RunRunApp)
2. Välj target **RunRunApp**
3. Gå till **Frameworks, Libraries, and Embedded Content**
4. Kontrollera att **RunRuniOS** finns där
5. Om inte, klicka **+** och lägg till den

## Verifiera att det fungerar

Paketen bygger korrekt från kommandoraden:

```bash
# Testa RunRunCore
cd /Users/katrin/runrun_ios/RunRunCore
swift build
# ✅ Build complete!

# Testa RunRuniOS
cd /Users/katrin/runrun_ios/RunRuniOS
swift build
# ✅ Build complete!
```

## Varför händer detta?

Xcode cachar Swift Package Manager-information och ibland uppdateras inte cacherna när nya filer läggs till i ett lokalt paket. Detta är ett känt problem med Xcode och SPM.

## Om ingenting fungerar

Som sista utväg, prova att:

1. Stäng Xcode helt
2. Radera alla Derived Data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Radera Xcode caches:
   ```bash
   rm -rf ~/Library/Caches/com.apple.dt.Xcode
   ```
4. Starta om datorn (ja, seriöst)
5. Öppna Xcode och projektet igen

## Förväntat resultat

Efter att ha följt någon av lösningarna ovan ska:
- EditorView.swift kompilera utan fel
- WorkoutStorage vara tillgänglig i scope
- Appen bygga och köra korrekt


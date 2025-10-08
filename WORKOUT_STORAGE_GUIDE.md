# Workout Storage & Sharing Guide

Den här guiden beskriver hur du sparar, hanterar och delar dina workouts i RunRun-appen.

## Översikt

RunRun har nu tre nya funktioner:
1. **Lokal lagring** - Spara dina workouts på enheten
2. **Workout Library** - Hantera och visa alla sparade workouts
3. **Delning** - Dela workouts med andra användare

## Komponenter

### 1. WorkoutStorage (Core)
**Fil:** `RunRunCore/Sources/RunRunCore/WorkoutStorage.swift`

Hanterar all lagring och import/export:
- **`save()`** - Sparar workout lokalt med UserDefaults
- **`loadAll()`** - Laddar alla sparade workouts
- **`delete()`** - Tar bort en workout
- **`exportForSharing()`** - Exporterar till JSON för delning
- **`exportToFile()`** - Skapar en `.runrun`-fil för delning
- **`importFromData()`** - Importerar från JSON-data
- **`importFromFile()`** - Importerar från fil

### 2. WorkoutLibraryView (iOS)
**Fil:** `RunRuniOS/Sources/RunRuniOS/WorkoutLibraryView.swift`

Huvudvyn för att visa och hantera workouts:
- Lista alla sparade workouts
- Kör en workout direkt från biblioteket
- Dela workout med andra
- Ta bort workouts
- Importera workouts från fil eller text

### 3. EditorView (Uppdaterad)
**Fil:** `RunRuniOS/Sources/RunRuniOS/EditorView.swift`

Nu med spara-funktion:
- Skapa nya workouts
- Spara till biblioteket med titel och anteckningar
- Validera och förhandsgranska

### 4. MainAppView
**Fil:** `RunRuniOS/Sources/RunRuniOS/MainAppView.swift`

Tab-baserad huvudvy:
- Tab 1: Library (visa sparade workouts)
- Tab 2: Editor (skapa nya workouts)

## Användning

### Spara en Workout

1. Öppna **Editor**-tabben
2. Skriv ditt program (t.ex. `P10 (x3 W60 R20)`)
3. Tryck **Förhandsvisa** för att validera
4. Tryck **Save**-knappen
5. Ange titel och valfria anteckningar
6. Tryck **Save** i dialogen

### Köra en Sparad Workout

1. Öppna **Library**-tabben
2. Hitta din workout i listan
3. Tryck på play-ikonen ▶️
4. Workout startar direkt i RunView

### Dela en Workout

1. Öppna **Library**-tabben
2. Hitta workout du vill dela
3. Tryck **Share**
4. Välj hur du vill dela (AirDrop, iMessage, Email, etc.)
5. En `.runrun`-fil skickas till mottagaren

### Importera en Workout

#### Från Fil (.runrun)
1. Ta emot filen (t.ex. via AirDrop eller Mail)
2. Öppna appen
3. Gå till **Library**
4. Tryck på ⬇️ (import) i navigationsbaren
5. Välj **Import from File**
6. Välj `.runrun`-filen
7. Workout sparas automatiskt i biblioteket

#### Från Text
1. Gå till **Library**
2. Tryck på ⬇️ (import)
3. Välj **Import from Text**
4. Klistra in programsträngen
5. Ange titel
6. Tryck **Import**

### Ta Bort en Workout

1. Öppna **Library**
2. Hitta workout du vill ta bort
3. Tryck **Delete**
4. Workout tas bort permanent

## Filformat

### .runrun-fil (JSON)
```json
{
  "version": 1,
  "id": "wtk_A1B2C3",
  "title": "HIIT Session",
  "notes": "Hard intervals",
  "program": "P10 (x3 W60 R20)",
  "createdAt": "2025-10-08T12:00:00Z",
  "author": "user"
}
```

### Fält
- **version**: Format-version (alltid 1)
- **id**: Unikt ID för workout
- **title**: Namn på workout
- **notes**: Beskrivning/anteckningar
- **program**: RunRun-programsträng
- **createdAt**: ISO8601 timestamp
- **author**: Skapare (standard: "user")

## Integration i din App

### Använd MainAppView
```swift
import SwiftUI
import RunRuniOS

@main
struct RunRunApp: App {
    var body: some Scene {
        WindowGroup {
            MainAppView()
        }
    }
}
```

### Eller använd komponenter separat
```swift
// Endast Library
WorkoutLibraryView()

// Endast Editor
EditorView()

// Custom integration
WorkoutStorage().loadAll() // Få alla workouts
```

## Tekniska Detaljer

### Lagring
- Använder `UserDefaults` för enkel lokal lagring
- Alla workouts sparas som JSON-array
- Nyckel: `"com.runrun.saved_workouts"`

### Delning
- Använder iOS Share Sheet (`UIActivityViewController`)
- Exporterar som `.runrun`-fil (JSON)
- Stöder AirDrop, iMessage, Email, etc.

### Import
- Stöder både fil-import och text-import
- Validerar program före import
- Automatisk dubletthantering (samma titel = uppdatera)

## Framtida Förbättringar

Möjliga tillägg:
- [ ] iCloud-synkning mellan enheter
- [ ] Workout-kategorier/taggar
- [ ] Favorit-markering
- [ ] Sökfunktion i biblioteket
- [ ] Sortering (datum, namn, längd)
- [ ] Workout-historik (när du körde dem)
- [ ] Statistik per workout
- [ ] Export till andra format (CSV, PDF)
- [ ] QR-kod för snabb delning

## Support

Om du har frågor eller problem:
- Kolla att programsträngen är giltig med **Validera**
- Kontrollera att titeln inte är tom vid sparning
- Verifiera att `.runrun`-filer är giltig JSON


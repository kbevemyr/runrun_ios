# Apple Watch Synkroniserings-Guide

## Översikt

RunRun-appen stödjer nu automatisk synkronisering av workouts mellan iPhone och Apple Watch via WatchConnectivity Framework.

## Funktioner

### ✅ Implementerat

1. **Automatisk synkronisering**
   - Workouts synkas automatiskt när de skapas, uppdateras eller tas bort på iPhone
   - Ändringar på iPhone skickas direkt till Apple Watch när den är nåbar
   - Fallback till Application Context när Watch inte är aktivt nåbar

2. **Tvåvägssynkronisering**
   - iOS kan skicka workouts till Watch
   - iOS kan hämta workouts från Watch
   - Automatisk merge av workouts (inga dubbletter)

3. **Watch-app funktioner**
   - Lista över alla synkade workouts
   - Köra workouts direkt från Watch
   - Manuell synkronisering via "Synka"-knapp
   - Visar workout-detaljer (intervaller, total tid)

4. **iOS-app funktioner**
   - Ny "Watch"-flik för synkroniseringsstatus
   - Visar om Watch är parad, app installerad, och nåbar
   - Manuella synkroniseringsknappar
   - Automatisk push när workouts sparas

## Arkitektur

### WatchConnectivityManager
**Plats:** `RunRunCore/Sources/RunRunCore/WatchConnectivityManager.swift`

Central manager som hanterar all kommunikation mellan iOS och watchOS:
- Singleton-pattern (`shared`)
- Observerbar via `@Published` properties
- Hanterar både realtidsmeddelanden (när Watch är aktiv) och context-uppdateringar (för bakgrundssynk)

### WorkoutStorage med Watch-sync
**Plats:** `RunRunCore/Sources/RunRunCore/WorkoutStorage.swift`

Uppdaterad för att automatiskt synka:
- `save()` - Synkar till Watch när workout sparas
- `delete()` - Synkar till Watch när workout tas bort
- `pushToWatch()` - Manuell push av alla workouts
- `requestSyncFromWatch()` - Begär workouts från Watch
- Automatisk merge av mottagna workouts (ingen överskrivning av befintliga)

### WatchWorkoutListView
**Plats:** `RunRunWatch/Sources/RunRunWatch/WatchWorkoutListView.swift`

watchOS-vy som visar alla synkade workouts:
- Lista med alla workouts
- Tryck för att köra workout
- Synka-knapp för manuell uppdatering
- Visar intervaller och total tid
- Empty state när inga workouts finns

### WatchSyncView
**Plats:** `RunRuniOS/Sources/RunRuniOS/WatchSyncView.swift`

iOS-vy för Watch-hantering:
- Status-information (parad, installerad, nåbar)
- Antal synkade workouts
- Manuella synkroniseringsknappar
- Informationstext om funktionalitet

## Användning

### För slutanvändare

#### På iPhone:
1. Skapa workouts i Editor-fliken
2. Spara workouts i Library
3. Workouts synkas automatiskt till Apple Watch
4. Kontrollera synkronisering i "Watch"-fliken

#### På Apple Watch:
1. Öppna RunRun-appen
2. Se lista över synkade workouts
3. Tryck på workout för att köra
4. Använd "Synka"-knappen för att uppdatera listan manuellt

### För utvecklare

#### Initiera WatchConnectivity:
```swift
// iOS
@StateObject private var connectivity = WatchConnectivityManager.shared

// watchOS
init() {
    _ = WatchConnectivityManager.shared
}
```

#### Skicka workouts från iOS till Watch:
```swift
let storage = WorkoutStorage()
storage.pushToWatch() // Skickar alla workouts
```

#### Begära workouts från Watch:
```swift
storage.requestSyncFromWatch()
```

#### Lyssna på mottagna workouts:
```swift
WatchConnectivityManager.shared.onWorkoutsReceived { workouts in
    // Hantera mottagna workouts
    print("Fick \(workouts.count) workouts")
}
```

## Tekniska detaljer

### Kommunikationsmetoder

1. **Interactive Messaging** (när Watch är aktiv):
   - Snabb, realtidskommunikation
   - Kräver att Watch-appen är aktiv
   - Används för manuella sync-förfrågningar

2. **Application Context** (bakgrundssynk):
   - Används när Watch inte är aktivt nåbar
   - Senaste context levereras när Watch vaknar
   - Automatisk fallback från messaging

### Dataformat

Workouts skickas som JSON-kodade `WorkoutExport`-objekt:
```swift
{
  "id": "UUID",
  "title": "Workout Name",
  "program": "W30 R10 W30 R10",
  "notes": "Optional notes",
  "author": "user",
  "createdAt": "2025-10-08T12:00:00Z"
}
```

### Merge-strategi

När workouts tas emot från Watch:
- Befintliga workouts (baserat på ID) behålls
- Nya workouts läggs till
- Ingen överskrivning av lokala workouts
- Detta förhindrar dataförlust vid konflikter

## Testning

### Simulatorer
Du kan testa synkronisering med Xcode simulatorer:
1. Kör iOS-appen i iPhone-simulator
2. Kör watchOS-appen i Apple Watch-simulator
3. Simulatorerna kan kommunicera via WatchConnectivity

### Verkliga enheter
För bästa resultat, testa med:
- Fysisk iPhone
- Parad Apple Watch
- Båda apparna installerade

### Testscenarion
1. ✅ Skapa workout på iPhone → Visas på Watch
2. ✅ Ta bort workout på iPhone → Tas bort från Watch
3. ✅ Manuell synk från Watch → Hämtar nya workouts
4. ✅ Watch i bakgrunden → Får uppdateringar vid nästa aktivering

## Felsökning

### Watch syns inte som parad
- Kontrollera att Watch är parad i Watch-appen på iPhone
- Aktivera Bluetooth
- Starta om båda enheterna

### Workouts synkar inte
- Kontrollera att Watch-appen är installerad
- Öppna Watch-appen minst en gång
- Tryck "Synka" manuellt i Watch-appen
- Kontrollera Console.app för debug-meddelanden

### Watch är inte nåbar
- Detta är normalt när Watch är i bakgrunden
- Workouts synkas ändå via Application Context
- Öppna Watch-appen för realtidssynk

## Framtida förbättringar

### Möjliga tillägg:
- [ ] Konfliktlösning (välj iOS eller watchOS version vid konflikt)
- [ ] Tvåvägslösning av workout-ändringar
- [ ] Synkhistorik och logg
- [ ] iCloud-synk för backup
- [ ] Komplication för snabb åtkomst
- [ ] Notifikationer när nya workouts finns tillgängliga

## API-referens

### WatchConnectivityManager

```swift
// Properties
@Published var isReachable: Bool
@Published var isPaired: Bool
@Published var isWatchAppInstalled: Bool

// Methods
func syncWorkouts(_ workouts: [WorkoutExport])
func requestWorkouts()
func onWorkoutsReceived(_ handler: @escaping ([WorkoutExport]) -> Void)
```

### WorkoutStorage

```swift
// Nya Watch-relaterade methods
func requestSyncFromWatch()
func pushToWatch()

// Befintliga methods synkar nu automatiskt
func save(workout: Workout, title: String, notes: String, author: String) throws
func delete(id: String) throws
```

## Säkerhet & Privacy

- Ingen data skickas till molnet
- All kommunikation sker direkt mellan parade enheter
- Workouts lagras lokalt på varje enhet
- UserDefaults används för lokal lagring

## Prestanda

- Minimal batteriförbrukning
- Effektiv datakomprimering via JSON
- Intelligent fallback mellan messaging och context
- Inga onödiga synkningar

---

**Skapad:** 2025-10-08  
**Version:** 1.0  
**Författare:** RunRun Development Team


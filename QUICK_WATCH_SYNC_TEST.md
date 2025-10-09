# Snabbguide: Testa Watch-synkronisering

## Snabbstart med simulatorer

### Steg 1: Starta iOS-appen
```bash
cd RunRunApp/RunRunApp
open RunRunApp.xcodeproj
```

1. Välj iPhone-simulator (t.ex. iPhone 15 Pro)
2. Kör appen (⌘R)
3. Appen öppnas med 3 flikar: Library, Editor, Watch

### Steg 2: Skapa en workout på iPhone
1. Gå till "Editor"-fliken
2. Skriv ett program, t.ex: `W60 R30 W60 R30`
3. Tryck "Preview" för att kontrollera
4. Tryck "Save Workout"
5. Ange ett namn, t.ex. "Morgonlöpning"
6. Sparad workout syns nu i "Library"-fliken

### Steg 3: Kontrollera Watch-status
1. Gå till "Watch"-fliken
2. Du ser status för Watch-anslutningen:
   - **Parad:** Ja/Nej
   - **App installerad:** Ja/Nej
   - **Nåbar:** Ja/Nej

*OBS: Med simulatorer kan status variera. Det är OK!*

### Steg 4: Starta watchOS-appen
```bash
cd TestApps/watchOS
swift build
# Eller öppna i Xcode och välj Apple Watch simulator
```

1. Välj Apple Watch-simulator (t.ex. Apple Watch Series 9)
2. Kör watchOS test-appen
3. Du ser antingen:
   - Lista med synkade workouts (om synk fungerade)
   - "Inga Workouts" (om synk inte skett än)

### Steg 5: Synka manuellt
**På Watch:**
1. Tryck "Synka med iPhone"-knappen
2. Vänta 2-3 sekunder
3. Workouts från iPhone dyker upp i listan

**På iPhone:**
1. Gå till "Watch"-fliken
2. Tryck "Synka till Watch"
3. Bekräftelse visas

### Steg 6: Kör en workout på Watch
1. Tryck på en workout i listan
2. Workout-vyn öppnas med:
   - Aktuell intervaltyp (Walk/Run)
   - Timer
   - Progress (1/4 osv.)
   - Start/Pausa-knapp
   - Hoppa-knapp
3. Tryck "Start" för att börja
4. Timern räknar ned
5. Testa "Pausa" och "Hoppa"

## Med riktiga enheter

### Förberedelser
1. Fysisk iPhone med utvecklarcertifikat
2. Parad Apple Watch
3. Installera iOS-appen på iPhone
4. Installera watchOS-appen på Watch

### Test
1. **Skapa workout på iPhone**
   - Öppna RunRun på iPhone
   - Gå till Editor
   - Skapa och spara workout

2. **Automatisk synk**
   - Workout synkas automatiskt till Watch
   - Öppna RunRun på Watch
   - Workout visas i listan

3. **Kör på Watch**
   - Tryck på workout
   - Tryck "Start"
   - Träningspasset körs med haptic feedback (om implementerat)

## Felsökning

### Workouts syns inte på Watch
**Lösning 1: Manuell synk**
- Öppna Watch-appen
- Tryck "Synka med iPhone"

**Lösning 2: Kontrollera anslutning**
- iPhone: Öppna Watch-fliken
- Kontrollera att "Nåbar" är "Ja"
- Om nej, öppna Watch-appen för att aktivera anslutningen

**Lösning 3: Starta om**
- Stäng båda apparna
- Starta iPhone-appen först
- Sen Watch-appen

### "Watch är inte parad" på iPhone
**Med simulatorer:**
- Detta är normalt
- Synk kan ändå fungera via Application Context
- Testa manuell synk

**Med riktiga enheter:**
- Kontrollera att Watch är parad i Watch-appen
- Aktivera Bluetooth
- Starta om båda enheterna

### Workouts dupliceras
- Detta borde inte hända (merge-logik förhindrar det)
- Om det händer: rapportera som bug
- Tillfällig lösning: Ta bort duplikater manuellt i Library

## Debug-tips

### Console-meddelanden
Kör med Xcode för att se debug-utskrifter:
```
WCSession aktiverad med state: 2
Watch reachability: true
Synkade 3 workouts från Watch
Workouts skickade via meddelande: [status: success]
```

### Verifiera data
**iPhone:**
```swift
// I WorkoutLibraryViewModel
print("Antal workouts: \(workouts.count)")
```

**Watch:**
```swift
// I WatchWorkoutListViewModel
print("Laddade workouts: \(workouts.count)")
```

## Nästa steg

Efter framgångsrik synkronisering, testa:
1. ✅ Skapa flera workouts på iPhone
2. ✅ Ta bort workout på iPhone (synkar automatiskt)
3. ✅ Uppdatera workout (spara med samma namn)
4. ✅ Testa med Watch i bakgrunden
5. ✅ Testa med Watch avstängd och sedan påslagen

## Förväntade resultat

| Action | iPhone | Watch |
|--------|--------|-------|
| Skapa workout | Sparas i Library | Synkas automatiskt |
| Ta bort workout | Försvinner från Library | Försvinner från Watch* |
| Uppdatera workout | Uppdateras i Library | Synkas automatiskt |
| Manuell synk från Watch | - | Hämtar alla workouts |
| Manuell synk till Watch | Skickar alla | Tar emot alla |

*OBS: Delete-synk är inte helt implementerad än. Det kan krävas manuell radering på Watch.

## Kända begränsningar

1. **Ingen delete-propagering** (än)
   - Ta bort på iPhone synkar inte automatiskt till Watch
   - Workaround: Manuell radering på Watch

2. **Ingen konflikthantering**
   - Om samma workout ändras på båda enheter samtidigt
   - Senaste ändringen vinner (baserat på merge-logik)

3. **Simulator-begränsningar**
   - WatchConnectivity kan vara instabil i simulatorn
   - Rekommenderas: Testa med riktiga enheter för bäst resultat

---

**Tips:** Börja enkelt med 1-2 workouts för att verifiera att synken fungerar, sedan testa med fler!


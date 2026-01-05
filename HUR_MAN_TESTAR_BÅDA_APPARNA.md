# Hur man testar Watch-appen och iOS-appen tillsammans

## ⚠️ VIKTIG VARNING: WatchConnectivity och Simulatorer

**WatchConnectivity Framework fungerar INTE mellan simulatorer.**

Detta är en teknisk begränsning från Apple - WatchConnectivity kräver fysisk Bluetooth-anslutning mellan parade enheter, vilket simulatorer saknar.

**Vad detta betyder:**
- ❌ Du kan **INTE** testa synkronisering mellan iOS- och Watch-simulatorer
- ❌ `isReachable` kommer alltid vara `false` mellan simulatorer
- ❌ Application Context fungerar inte heller mellan simulatorer
- ✅ Du **KAN** testa apparna individuellt i simulatorer (UI, lokal lagring, funktionalitet)
- ✅ Du **MÅSTE** använda riktiga enheter (iPhone + Apple Watch) för att testa WatchConnectivity

**Rekommendation:** Använd simulatorer för UI-utveckling och riktiga enheter för WatchConnectivity-testning.

---

## Översikt

Det finns flera sätt att testa både iOS-appen och Watch-appen. Detta dokument beskriver de olika metoderna och när de är lämpliga att använda.

## Metod 1: Kör båda i separata Xcode-fönster (Rekommenderat)

Detta är den enklaste metoden när du utvecklar och testar båda apparna samtidigt.

### Steg 1: Öppna projektet första gången
```bash
cd /Users/katrin/runrun_ios/RunRunTimer
open RunRunTimer.xcodeproj
```

### Steg 2: Kör iOS-appen först
1. I Xcode, välj scheme **"RunRunTimer"** (iOS-appen)
2. Välj en iPhone-simulator (t.ex. iPhone 15 Pro)
3. Tryck **⌘R** för att köra
4. iOS-appen startar i simulatorn

### Steg 3: Öppna projektet igen i ett nytt fönster
**Alternativ A: Via Finder**
1. Öppna Finder
2. Navigera till `/Users/katrin/runrun_ios/RunRunTimer`
3. **Dubbelklicka** på `RunRunTimer.xcodeproj`
4. Ett nytt Xcode-fönster öppnas med samma projekt

**Alternativ B: Via Terminal**
```bash
# I ett nytt terminalfönster:
cd /Users/katrin/runrun_ios/RunRunTimer
open -a Xcode RunRunTimer.xcodeproj
```

**Alternativ C: Via Xcode**
1. I det första Xcode-fönstret: **File → Open Recent → RunRunTimer.xcodeproj**
2. Om det inte fungerar, använd Finder-metoden ovan

### Steg 4: Kör Watch-appen i det nya fönstret
1. I det nya Xcode-fönstret, välj scheme **"RunRunTimer Watch App Watch App"**
2. Välj en Apple Watch-simulator (t.ex. Apple Watch Series 9)
3. Tryck **⌘R** för att köra
4. Watch-appen startar i Watch-simulatorn

### Steg 5: Testa synkronisering
Nu har du båda simulatorerna igång samtidigt:
- **iPhone-simulatorn** med iOS-appen
- **Watch-simulatorn** med Watch-appen

**Testa synkronisering:**
1. I iOS-appen: Skapa en workout i Editor-fliken
2. Spara workouten
3. I Watch-appen: Tryck "Synka med iPhone"
4. Workouten bör nu synas i Watch-appen

---

## Metod 2: Byt scheme i samma Xcode-fönster (Enklast)

Om du inte behöver debugga båda samtidigt, kan du köra dem sekventiellt i samma fönster.

### Steg 1: Kör iOS-appen
1. Öppna Xcode-projektet
2. Välj scheme **"RunRunTimer"**
3. Välj iPhone-simulator
4. Tryck **⌘R**
5. iOS-appen startar

### Steg 2: Byt till Watch-appen
1. **Stoppa** iOS-appen (⌘.) om den körs
2. Byt scheme till **"RunRunTimer Watch App Watch App"**
3. Välj Apple Watch-simulator
4. Tryck **⌘R**
5. Watch-appen startar

**OBS:** iOS-simulatorn kan vara kvar igång i bakgrunden, så du kan växla mellan dem.

### Steg 3: Testa synkronisering
1. Starta iOS-appen igen (byt scheme och kör)
2. Skapa en workout
3. Byt till Watch-appen (byt scheme och kör)
4. Synka manuellt i Watch-appen

---

## Metod 3: Testa apparna separat i simulatorer (När WatchConnectivity inte behövs)

Eftersom WatchConnectivity inte fungerar mellan simulatorer, kan du testa apparna separat för att verifiera att de fungerar individuellt.

### Vad du kan testa:

**iOS-appen:**
- ✅ Skapa workouts i Editor
- ✅ Spara workouts lokalt
- ✅ Visa workouts i Library
- ✅ UI och navigation
- ✅ Lokal lagring fungerar

**Watch-appen:**
- ✅ Ladda workouts lokalt (om de redan finns i UserDefaults)
- ✅ Visa workout-lista
- ✅ Köra workouts
- ✅ Timer-funktionalitet
- ✅ UI och navigation

### Begränsningar:
- ❌ Ingen synkronisering mellan apparna
- ❌ Watch-appen kommer inte se workouts skapade i iOS-appen
- ❌ iOS-appen kommer inte se workouts skapade i Watch-appen

---

## Metod 3b: Använd terminal för att köra en av apparna

Om Xcode-fönster-metoden inte fungerar, kan du köra en app via terminal.

### Steg 1: Kör iOS-appen i Xcode
1. Öppna projektet i Xcode
2. Välj scheme "RunRunTimer"
3. Välj iPhone-simulator
4. Tryck **⌘R**

### Steg 2: Kör Watch-appen via terminal
Öppna ett nytt terminalfönster och kör:
```bash
cd /Users/katrin/runrun_ios/RunRunTimer

# Lista tillgängliga simulatorer
xcrun simctl list devices available | grep "Apple Watch"

# Bygg och kör Watch-appen (ersätt med rätt simulator-ID)
xcodebuild -project RunRunTimer.xcodeproj \
  -scheme "RunRunTimer Watch App Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  build

# Starta Watch-simulatorn
xcrun simctl boot "Apple Watch Series 9 (45mm)"

# Installera appen (efter build)
# xcodebuild -project RunRunTimer.xcodeproj \
#   -scheme "RunRunTimer Watch App Watch App" \
#   -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
#   install
```

**OBS:** Denna metod är mer komplicerad. Rekommenderar att använda Finder-metoden (Metod 1) istället.

---

## Metod 4: Kör med riktiga enheter (ENDAST sättet att testa WatchConnectivity)

⚠️ **VIKTIGT:** WatchConnectivity fungerar **ENDAST** mellan riktiga parade enheter. Detta är det **enda sättet** att testa synkronisering mellan iOS och watchOS.

För bästa resultat och full WatchConnectivity-funktionalitet, testa med fysiska enheter.

### Förutsättningar
- Fysisk iPhone med utvecklarcertifikat
- Apple Watch parad med iPhone
- Båda enheterna anslutna till Mac via USB/kabel

### Steg 1: Anslut iPhone
1. Anslut iPhone till Mac med USB-kabel
2. Öppna Xcode
3. Välj din iPhone som destination
4. Klicka "Trust" på iPhone om det frågas

### Steg 2: Installera iOS-appen
1. Välj scheme **"RunRunTimer"**
2. Välj din iPhone som destination
3. Tryck **⌘R**
4. iOS-appen installeras och startar på iPhone

### Steg 3: Installera Watch-appen
1. Välj scheme **"RunRunTimer Watch App Watch App"**
2. Välj din Apple Watch som destination (den visas automatiskt när Watch är parad)
3. Tryck **⌘R**
4. Watch-appen installeras och startar på Watch

### Steg 4: Testa synkronisering
Nu har du båda apparna på riktiga enheter:
- ✅ WatchConnectivity fungerar fullt ut
- ✅ Workouts synkas automatiskt via WatchConnectivity
- ✅ `isReachable` kommer vara `true` när båda apparna är aktiva
- ✅ Testa att skapa workouts på iPhone och se dem på Watch
- ✅ Testa att köra workouts direkt på Watch
- ✅ Testa Application Context-synk (när Watch är i bakgrunden)

---

## Metod 5: Debug båda samtidigt

För avancerad debugging kan du ha båda apparna i debug-läge samtidigt.

### Steg 1: Starta iOS-appen i debug
1. Öppna projektet i Xcode (via Finder eller terminal)
2. Välj scheme "RunRunTimer"
3. Sätt breakpoints i iOS-koden
4. Tryck **⌘R** för att köra i debug-läge

### Steg 2: Starta Watch-appen i debug (nytt fönster)
1. **Öppna projektet igen** via Finder (dubbelklicka på `.xcodeproj`-filen)
2. I det nya Xcode-fönstret, välj scheme "RunRunTimer Watch App Watch App"
3. Sätt breakpoints i Watch-koden
4. Tryck **⌘R** för att köra i debug-läge

### Steg 3: Debug båda samtidigt
- Båda apparna har nu sina egna debug-sessioner
- Breakpoints i båda apparna fungerar oberoende
- Du kan se console-utskrifter från båda apparna
- Du kan inspektera variabler i båda apparna

---

## Testscenarion att köra

### 1. Grundläggande synkronisering
- [ ] Skapa workout på iPhone → Kontrollera att den synkas till Watch
- [ ] Ta bort workout på iPhone → Kontrollera att den försvinner på Watch
- [ ] Uppdatera workout på iPhone → Kontrollera att ändringen synkas

### 2. Tvåvägssynkronisering
- [ ] Skapa workout på Watch → Kontrollera att den synkas till iPhone
- [ ] Manuell synk från Watch → Verifiera att alla workouts hämtas
- [ ] Manuell synk till Watch från iPhone → Verifiera att alla workouts skickas

### 3. Edge cases
- [ ] Starta Watch-appen innan iOS-appen → Verifiera att synk fungerar
- [ ] Stäng Watch-appen medan iOS-appen är aktiv → Skapa workout → Öppna Watch → Verifiera att workout synkas
- [ ] Testa med Watch i bakgrunden → Verifiera Application Context-synk

### 4. Workout-körning
- [ ] Starta workout på Watch → Verifiera att timern fungerar
- [ ] Pausa workout → Verifiera att paus fungerar
- [ ] Hoppa intervall → Verifiera att hopp fungerar
- [ ] Slutför workout → Verifiera att workout avslutas korrekt

---

## Tips och tricks

### Snabb iteration
- Använd SwiftUI Previews för snabb UI-iteration
- Tryck **⌥⌘↩** för att öppna Canvas
- Ändringar i previews kräver ingen full rebuild

### Console-debugging
Båda apparna skriver debug-meddelanden:
- iOS: Sök efter "WatchConnectivity" i console
- Watch: Sök efter "Synkade workouts" i console

### ⚠️ VIKTIGT: WatchConnectivity fungerar INTE mellan simulatorer

**Detta är en känd begränsning i iOS/watchOS-utveckling:**
- WatchConnectivity Framework fungerar **endast** mellan riktiga parade enheter
- Simulatorer kan **inte** kommunicera med varandra via WatchConnectivity
- `isReachable` kommer alltid vara `false` mellan simulatorer
- Application Context fungerar inte heller mellan simulatorer

**Vad du KAN testa i simulatorer:**
- ✅ UI och layout på båda plattformarna
- ✅ Lokal lagring (workouts sparas lokalt på varje simulator)
- ✅ Workout-körning och timer-funktionalitet
- ✅ App-navigation och användarflöden

**Vad du INTE kan testa i simulatorer:**
- ❌ WatchConnectivity-synkronisering
- ❌ Automatisk synk mellan iOS och watchOS
- ❌ Realtidskommunikation mellan apparna

**Lösning:** Använd riktiga enheter för att testa WatchConnectivity (se Metod 4 nedan)

### Prestanda
- Kör båda simulatorerna på samma Mac kan vara resurskrävande
- Överväg att stänga andra applikationer
- Använd riktiga enheter för prestandatestning

---

## Felsökning

### Kan inte öppna projektet i nytt fönster
**Lösning:**
- Använd **Finder** och dubbelklicka på `RunRunTimer.xcodeproj`-filen
- Eller använd terminal: `open -a Xcode RunRunTimer.xcodeproj`
- Xcode tillåter inte att öppna samma projekt två gånger via "File → Open"

### Watch-appen startar inte
**Lösning:**
1. Kontrollera att Watch-simulatorn är öppen
2. Öppna Simulator-appen: **File → Open Simulator → watchOS → Apple Watch Series 9**
3. Försök köra igen

### Synkronisering fungerar inte mellan simulatorer
**Detta är förväntat beteende!**

**Om du kör i simulatorer:**
- WatchConnectivity fungerar **inte** mellan simulatorer
- Detta är en teknisk begränsning från Apple
- Du kan bara testa apparna individuellt

**Om du kör på riktiga enheter:**
1. Kontrollera att båda enheterna är parade
2. Kontrollera att båda apparna är installerade
3. I iOS-appen, gå till "Watch"-fliken och kontrollera status
   - "Parad" ska vara "Ja"
   - "App installerad" ska vara "Ja"
   - "Nåbar" kan vara "Nej" om Watch-appen inte är aktiv
4. Öppna Watch-appen för att göra den nåbar
5. I Watch-appen, tryck "Synka med iPhone" manuellt
6. Kontrollera console för debug-meddelanden
7. Om det fortfarande inte fungerar, starta om båda enheterna

### WatchConnectivity fungerar inte mellan simulatorer
**Detta är en teknisk begränsning, inte ett fel!**

**Varför:**
- WatchConnectivity Framework kräver fysisk Bluetooth-anslutning
- Simulatorer saknar denna anslutning
- Apple har inte implementerat WatchConnectivity-stöd mellan simulatorer

**Lösningar:**

**1. Testa apparna separat:**
- Kör iOS-appen och testa att skapa/spara workouts lokalt
- Kör Watch-appen och testa att ladda workouts lokalt
- Verifiera att UI och funktionalitet fungerar individuellt

**2. Använd riktiga enheter (rekommenderat):**
- WatchConnectivity fungerar perfekt mellan fysisk iPhone och Apple Watch
- Se "Metod 4: Kör med riktiga enheter" ovan

**3. Testa manuellt med delad lagring (för utveckling):**
- Du kan temporärt dela UserDefaults mellan simulatorer för testning
- Detta är bara för utveckling, inte produktion

### Build-fel
**Lösning:**
```bash
# Rensa build-cache
rm -rf ~/Library/Developer/Xcode/DerivedData/RunRunTimer-*

# Rensa Package cache
rm -rf ~/Library/Caches/org.swift.swiftpm

# Öppna Xcode igen
# File → Packages → Reset Package Caches
```

---

## Rekommenderat arbetsflöde

### För daglig utveckling (i simulatorer):
1. **Starta iOS-appen** i iPhone-simulator
2. **Testa UI och funktionalitet** individuellt
3. **Starta Watch-appen** i Watch-simulator (separat)
4. **Testa UI och funktionalitet** individuellt
5. **OBS:** Synkronisering fungerar INTE mellan simulatorer
6. **Iterera** på funktionalitet

### För WatchConnectivity-testning:
1. **Använd riktiga enheter** (iPhone + Apple Watch)
2. **Installera båda apparna** på fysiska enheter
3. **Testa synkronisering** - detta fungerar bara på riktiga enheter
4. **Verifiera** att workouts synkas korrekt

### För release-testning:
1. **Testa på riktiga enheter** (iPhone + Watch)
2. **Verifiera alla testscenarion**
3. **Testa prestanda** och batteriförbrukning
4. **Testa edge cases** och felhantering

---

## Ytterligare resurser

- `QUICK_WATCH_SYNC_TEST.md` - Snabbguide för synkroniseringstest
- `WATCH_SYNC_GUIDE.md` - Detaljerad guide om WatchConnectivity
- `HOW_TO_RUN_WATCH_APP.md` - Guide för att köra Watch-appen ensam

---

**Lycka till med testningen!** 🚀⌚️📱


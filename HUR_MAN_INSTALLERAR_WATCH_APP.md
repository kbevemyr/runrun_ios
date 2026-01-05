# Hur man installerar Watch-appen på Apple Watch

## ⚠️ Viktigt: Watch-appen installeras via iPhone

Watch-appar kan **INTE** installeras direkt på Apple Watch. De måste installeras via iPhone som är parad med Watch.

---

## Steg 1: Förutsättningar

Kontrollera att du har:
- ✅ iPhone ansluten till Mac
- ✅ Apple Watch parad med iPhone
- ✅ iOS-appen installerad på iPhone (se `HUR_MAN_KOOPLAR_IPHONE_TILL_MAC.md`)
- ✅ Båda enheterna upplåsta

---

## Steg 2: Installera iOS-appen först

Watch-appen kräver att iOS-appen är installerad först:

1. **Öppna Xcode-projektet**
2. **Välj scheme "RunRunTimer"** (iOS-appen)
3. **Välj din iPhone** som destination
4. **Tryck ⌘R** för att köra
5. **Vänta** tills iOS-appen är installerad och startad på iPhone

**OBS:** Watch-appen kan inte installeras om iOS-appen inte är installerad först.

---

## Steg 3: Konfigurera signering för Watch-appen

1. I Xcode, välj **projektet** i Project Navigator (blå ikon)
2. Välj **"RunRunTimer Watch App Watch App"** target
3. Gå till **"Signing & Capabilities"**-fliken
4. **Kryssa i "Automatically manage signing"**
5. **Välj samma Team** som du använder för iOS-appen
6. Xcode skapar automatiskt certifikat och provisioning profiles

**OBS:** 
- Watch-appen måste ha samma Team som iOS-appen
- Bundle Identifier ska vara `com.runrun.RunRunTimer.watchkitapp` (eller liknande)

---

## Steg 4: Installera Watch-appen

### Metod 1: Via Xcode (Rekommenderat)

1. I Xcode, välj scheme **"RunRunTimer Watch App Watch App"**
2. I destination-väljaren, du bör se din **Apple Watch** automatiskt
   - Den visas under din iPhone
   - Format: "iPhone Name's Apple Watch"
   - **Om Watch inte visas:** Se felsökningssektionen nedan
3. **Välj din Apple Watch** som destination
4. **Tryck ⌘R** för att köra
5. Xcode bygger både iOS-appen och Watch-appen
6. Watch-appen installeras automatiskt på Apple Watch via iPhone
7. Appen startar på Apple Watch

**OBS:** 
- Det kan ta några minuter första gången
- Watch-appen installeras via iPhone, inte direkt
- Båda enheterna måste vara upplåsta
- Om du får "No eligible device connected", se felsökningssektionen nedan

### Alternativ: Om Watch visas i Console men inte i destination-väljaren

Om Watch visas i Console/Console-appen men inte i Xcode's destination-väljare:

1. **Försök ändå:** Scrolla genom destination-listan - Watch kan finnas där ändå
2. **Eller:** Installera iOS-appen först - Watch-appen kan installeras automatiskt när iOS-appen installeras
3. **Eller:** Se felsökningssektionen för mer alternativ

### Metod 2: Automatisk installation via iOS-appen

När du installerar iOS-appen första gången:
- Om Watch är parad och upplåst, kan Watch-appen installeras automatiskt
- Om inte, följ Metod 1 ovan

---

## Steg 5: Verifiera installationen

### På iPhone:
1. Öppna **Watch-appen** på iPhone
2. Scrolla ned till **"Installerade på Apple Watch"**
3. Du bör se "RunRunTimer" i listan
4. Kontrollera att den är **aktiverad** (grön switch)

### På Apple Watch:
1. Tryck på **Digital Crown** på Watch
2. Scrolla genom apparna
3. Du bör se **RunRunTimer**-appen
4. Tryck på den för att öppna

---

## Felsökning

### "No eligible device connected" eller Watch visas inte i Xcode

Detta är ett vanligt problem. Följ dessa steg i ordning:

**Lösning 1: Kontrollera att iPhone är ansluten och synlig**
1. I Xcode, kontrollera att din **iPhone** visas i destination-väljaren
2. Om iPhone inte visas, följ stegen i `HUR_MAN_KOOPLAR_IPHONE_TILL_MAC.md`
3. iPhone måste vara ansluten via USB-kabel (för första gången)

**Lösning 2: Kontrollera parning mellan iPhone och Watch**
1. På iPhone, öppna **Watch-appen**
2. Kontrollera att din Apple Watch visas högst upp
3. Om Watch inte är parad:
   - Följ instruktionerna i Watch-appen för att para Watch
   - Detta kan ta några minuter

**Lösning 3: Kontrollera att båda enheterna är upplåsta**
- **iPhone** måste vara upplåst (inte på låsskärmen)
- **Apple Watch** måste vara upplåst (inte på låsskärmen)
- Båda måste vara påslagna och aktiva

**Lösning 4: Kontrollera i Xcode Devices and Simulators**
1. I Xcode: **Window → Devices and Simulators** (⌘⇧2)
2. Välj din **iPhone** i vänster lista
3. I höger panel, scrolla ned
4. Du bör se din **Apple Watch** listad under "Paired Apple Watch" eller liknande
   - Om Watch visas: Fortsätt till Lösning 5
   - Om Watch INTE visas: Se Lösning 6 nedan

**VIKTIGT:** Om Watch inte visas här, kommer den inte att visas i destination-väljaren heller.

**Lösning 5: Kontrollera Watch OS-version**
1. I Xcode: **Window → Devices and Simulators** (⌘⇧2)
2. Välj din Apple Watch
3. Kontrollera **watchOS-versionen**
4. Kontrollera att din Xcode-version stödjer denna watchOS-version
   - Om watchOS är för ny: Uppdatera Xcode
   - Om watchOS är för gammal: Uppdatera Watch (via Watch-appen på iPhone)

**Lösning 6: Om Watch INTE visas i Devices and Simulators**

Detta är det vanligaste problemet. Följ dessa steg noggrant:

**Steg 6a: Verifiera parning på iPhone**
1. På iPhone, öppna **Watch-appen**
2. Kontrollera att din Apple Watch visas högst upp med namn och bild
3. Om Watch inte är parad:
   - Följ instruktionerna i Watch-appen för att para Watch
   - Detta kan ta 5-10 minuter första gången
   - Vänta tills parningen är klar

**Steg 6b: Verifiera att Watch är upplåst och aktiv**
1. **Lås upp Apple Watch** (inte på låsskärmen)
2. Kontrollera att Watch är påslagen och aktiv
3. Kontrollera att Watch har batteri (minst 20%)

**Steg 6c: Koppla ur och koppla in iPhone**
1. **Koppla ur iPhone** från Mac
2. Vänta 5 sekunder
3. **Koppla in iPhone** igen till Mac
4. Vänta tills iPhone identifieras av Mac

**Steg 6d: Starta om Watch**
1. På Watch: Håll inne **sidoknappen** (längst ned till höger)
2. Vänta tills menyn visas
3. Välj **"Stäng av"** (eller swipea "Stäng av"-reglaget)
4. Vänta tills Watch är avstängd (svart skärm)
5. Starta om Watch: Håll inne **sidoknappen** tills Apple-loggan visas
6. Vänta tills Watch är startad och upplåst

**Steg 6e: Starta om Xcode**
1. **Stäng Xcode** helt (⌘Q)
2. Vänta 5 sekunder
3. **Öppna Xcode** igen
4. Öppna projektet igen

**Steg 6f: Kontrollera Devices and Simulators igen**
1. I Xcode: **Window → Devices and Simulators** (⌘⇧2)
2. Välj din **iPhone** i vänster lista
3. I höger panel, scrolla ned
4. **Vänta 10-30 sekunder** medan Xcode identifierar enheterna
5. Kontrollera om Watch nu visas under iPhone

**Om Watch fortfarande inte visas:**

**Steg 6g: Kontrollera Watch OS-version**
1. På iPhone, öppna **Watch-appen**
2. Gå till **Allmänt → Om**
3. Kontrollera **watchOS-versionen**
4. Kontrollera att din Xcode-version stödjer denna watchOS-version
   - Öppna Xcode → **Xcode → About Xcode** för att se Xcode-versionen
   - Om watchOS är för ny: Uppdatera Xcode
   - Om watchOS är för gammal: Uppdatera Watch (via Watch-appen på iPhone)

**Steg 6h: Kontrollera Bluetooth**
1. På iPhone: **Inställningar → Bluetooth**
2. Kontrollera att Bluetooth är **påslagen**
3. Kontrollera att Watch är ansluten (visas i listan)

**Steg 6i: Para Watch om**
1. På iPhone, öppna **Watch-appen**
2. Om Watch redan är parad: **Ta bort parningen** (Allmänt → Återställ → Ta bort Apple Watch-data)
3. Para Watch igen från början
4. Följ alla steg ovan igen

**Steg 6j: Kontrollera att iPhone är litad på**
1. På iPhone, när du kopplar in till Mac första gången
2. Du bör se: **"Lita på denna dator?"**
3. Tryck **"Lita på"**
4. Om du missade detta: Koppla ur och koppla in iPhone igen

**Lösning 7: Kontrollera signering**
1. I Xcode: Projekt → Target → **"RunRunTimer Watch App Watch App"**
2. Gå till **"Signing & Capabilities"**
3. Kontrollera att:
   - "Automatically manage signing" är ikryssad
   - Ett Team är valt (samma som iOS-appen)
   - Inga röda fel visas
4. Om det finns fel, fixa dem först

**Lösning 8: Kontrollera Bundle Identifier**
1. I Xcode: Projekt → Target → **"RunRunTimer Watch App Watch App"**
2. Gå till **"General"**-fliken
3. Kontrollera **Bundle Identifier**
   - Det ska vara: `com.runrun.RunRunTimer.watchkitapp` (eller liknande)
   - Det ska matcha iOS-appens Bundle Identifier med `.watchkitapp` i slutet
4. Om det är fel, ändra det

**Lösning 9: Rensa och bygg igen**
1. I Xcode: **Product → Clean Build Folder** (⌘⇧K)
2. Stäng Xcode
3. Starta om Xcode
4. Öppna projektet igen
5. Försök välja Watch som destination igen

**Lösning 10: Kontrollera att iOS-appen är installerad**
- Watch-appen kan inte installeras om iOS-appen inte är installerad först
- Installera iOS-appen (scheme "RunRunTimer" → iPhone → ⌘R)
- Vänta tills iOS-appen är installerad
- Försök sedan välja Watch som destination

### "Watch app is not installed" eller signeringsfel

**Lösning 1: Kontrollera signering**
1. I Xcode: Projekt → Target → "RunRunTimer Watch App Watch App"
2. Gå till "Signing & Capabilities"
3. Kryssa i "Automatically manage signing"
4. Välj samma Team som iOS-appen
5. Kontrollera att Bundle Identifier är korrekt

**Lösning 2: Rensa och bygg igen**
1. I Xcode: **Product → Clean Build Folder** (⌘⇧K)
2. **Product → Build** (⌘B)
3. Försök köra igen (⌘R)

**Lösning 3: Ta bort och installera om**
1. Ta bort iOS-appen från iPhone (håll inne app-ikonen → "Ta bort app")
2. Ta bort Watch-appen från Watch (via Watch-appen på iPhone)
3. Installera iOS-appen igen
4. Installera Watch-appen igen

### Watch-appen installeras men startar inte

**Lösning 1: Starta manuellt på Watch**
- Tryck på Digital Crown på Watch
- Hitta RunRunTimer-appen
- Tryck på den för att starta

**Lösning 2: Kontrollera Watch-appen på iPhone**
- Öppna Watch-appen på iPhone
- Scrolla till "Installerade på Apple Watch"
- Kontrollera att RunRunTimer är aktiverad (grön switch)
- Om inte, aktivera den

**Lösning 3: Starta om Watch**
- Håll inne sidoknappen på Watch
- Välj "Stäng av"
- Starta om Watch
- Försök öppna appen igen

### "Could not launch" på Watch

**Lösning:**
1. Kontrollera att Watch är upplåst
2. Kontrollera att Watch har batteri
3. Starta appen manuellt på Watch (via app-grid)
4. Om det fortfarande inte fungerar, installera om appen

### Watch-appen försvinner efter installation

**Detta kan hända om:**
- iOS-appen tas bort från iPhone
- Watch kopplas bort från iPhone
- Signering går ut

**Lösning:**
- Installera iOS-appen igen
- Installera Watch-appen igen via Xcode

---

## Tips och tricks

### Snabbare installation
- Använd **kabel** för iPhone (snabbare än trådlös)
- Håll båda enheterna upplåsta under installationen
- Stäng inte Xcode under installationen

### Debugging Watch-appen
- Du kan sätta **breakpoints** i Watch-koden
- Console-utskrifter visas i Xcode
- Du kan debugga både iOS och Watch samtidigt (i separata Xcode-fönster)

### Automatisk installation
- När du bygger iOS-appen, byggs Watch-appen automatiskt
- Om Watch är parad och upplåst, installeras Watch-appen automatiskt
- Du behöver inte alltid välja Watch som destination

### Ta bort Watch-appen
**Via iPhone:**
1. Öppna Watch-appen på iPhone
2. Scrolla till "Installerade på Apple Watch"
3. Hitta RunRunTimer
4. Stäng av switchen (eller swipea och tryck "Ta bort")

**Via Xcode:**
- Ta bort iOS-appen från iPhone
- Watch-appen tas bort automatiskt

---

## Vanliga frågor

### Watch visas inte i Devices and Simulators - vad gör jag?

Detta är det vanligaste problemet. Följ dessa steg i exakt ordning:

1. **Verifiera parning:** Öppna Watch-appen på iPhone → Kontrollera att Watch är parad
2. **Lås upp båda enheterna:** iPhone och Watch måste vara upplåsta
3. **Koppla ur/in iPhone:** Koppla ur iPhone från Mac, vänta 5 sek, koppla in igen
4. **Starta om Watch:** Håll inne sidoknappen → Stäng av → Starta om
5. **Starta om Xcode:** Stäng Xcode helt (⌘Q) → Öppna igen
6. **Kontrollera Devices and Simulators:** Window → Devices and Simulators (⌘⇧2) → Välj iPhone → Vänta 30 sek

Om Watch fortfarande inte visas:
- Kontrollera Watch OS-version vs Xcode-version (kompatibilitet)
- Kontrollera Bluetooth på iPhone
- Para Watch om från början

### Varför måste Watch-appen installeras via iPhone?
- Watch-appar är en del av iOS-appen (WatchKit Extension)
- De delar samma Bundle Identifier och signering
- Apple kräver att Watch-appar installeras via iPhone

### Kan jag installera Watch-appen direkt på Watch?
- Nej, Watch-appar måste alltid installeras via iPhone
- Detta är en teknisk begränsning från Apple

### Måste iPhone vara ansluten till Mac?
- För första installationen: Ja
- Efter det kan du använda trådlös anslutning (om aktiverad)

### Fungerar Watch-appen om iPhone-appen tas bort?
- Nej, Watch-appen tas bort automatiskt om iOS-appen tas bort
- De är kopplade till varandra

---

## Ytterligare resurser

- `HUR_MAN_KOOPLAR_IPHONE_TILL_MAC.md` - Guide för att koppla iPhone till Mac
- `HUR_MAN_TESTAR_BÅDA_APPARNA.md` - Guide för att testa båda apparna
- [Apple Developer - WatchKit](https://developer.apple.com/watchkit/)

---

**Lycka till med installationen!** ⌚📱


# Watch visas inte i Devices and Simulators - Specifik felsökning

## Problem
I Xcode's "Devices and Simulators" (⌘⇧2) visas bara iPhone, men ingen Apple Watch. Watch måste visas där för att kunna väljas som destination.

## Steg-för-steg lösning

### Steg 1: Verifiera parning på iPhone (VIKTIGAST)

1. **Öppna Watch-appen på iPhone**
   - Hitta och öppna "Watch"-appen på iPhone (grön ikon med klocka)
   
2. **Kontrollera att Watch är parad**
   - Överst i Watch-appen bör du se din Apple Watch med namn och bild
   - Om Watch INTE är parad:
     - Tryck på "Para Apple Watch"
     - Följ instruktionerna på skärmen
     - Detta kan ta 5-10 minuter
     - **Vänta tills parningen är helt klar**

3. **Kontrollera Watch-status**
   - I Watch-appen, scrolla ned
   - Kontrollera att Watch är ansluten och aktiv
   - Kontrollera batterinivån (bör vara minst 20%)

### Steg 2: Kontrollera att båda enheterna är upplåsta

**På iPhone:**
- Lås upp iPhone (inte på låsskärmen)
- iPhone måste vara aktiv och påslagen

**På Apple Watch:**
- Lås upp Watch (inte på låsskärmen)
- Watch måste vara aktiv och påslagen
- Kontrollera att Watch visar klockan (inte låsskärmen)

**VIKTIGT:** Båda enheterna måste vara upplåsta SAMTIDIGT när du kontrollerar i Xcode.

### Steg 3: Kontrollera Bluetooth

1. På iPhone: **Inställningar → Bluetooth**
2. Kontrollera att Bluetooth är **påslagen** (grön switch)
3. Kontrollera att din Apple Watch visas i listan över anslutna enheter
   - Om Watch inte visas: Se Steg 1 (parning)
   - Om Watch visas men är grå: Watch är inte aktiv, lås upp den

### Steg 4: Koppla ur och koppla in iPhone igen

1. **Koppla ur iPhone** från Mac (dra ut USB-kabeln)
2. **Vänta 5 sekunder**
3. **Koppla in iPhone igen** till Mac
4. **Vänta** tills Mac identifierar iPhone
5. På iPhone kan du behöva trycka "Lita på" om det frågas

### Steg 5: Starta om Apple Watch

1. **På Watch:** Håll inne **sidoknappen** (längst ned till höger)
2. **Vänta** tills menyn visas
3. **Swipea "Stäng av"-reglaget** eller tryck "Stäng av"
4. **Vänta** tills Watch är helt avstängd (svart skärm)
5. **Starta om Watch:** Håll inne **sidoknappen** tills Apple-loggan visas
6. **Vänta** tills Watch är startad och upplåst

### Steg 6: Starta om Xcode

1. **Stäng Xcode helt:**
   - Tryck **⌘Q** (eller Xcode → Quit Xcode)
   - Vänta tills Xcode är helt stängd
2. **Vänta 5 sekunder**
3. **Öppna Xcode igen**
4. **Öppna projektet** igen

### Steg 7: Kontrollera Devices and Simulators igen

1. I Xcode: **Window → Devices and Simulators** (⌘⇧2)
2. **Välj din iPhone** ("Katrin iPhone") i vänster lista
3. I **höger panel**, scrolla ned
4. **Vänta 10-30 sekunder** medan Xcode identifierar enheterna
5. **Kontrollera om Watch nu visas:**
   - Under iPhone i vänster lista, ELLER
   - I höger panel under "Paired Apple Watch" eller liknande

### Steg 8: Om Watch fortfarande inte visas

#### Kontrollera Watch OS-version

1. **På iPhone:** Öppna Watch-appen
2. Gå till **Allmänt → Om**
3. Kontrollera **watchOS-versionen** (t.ex. watchOS 10.2)
4. **I Xcode:** Xcode → About Xcode
5. Kontrollera **Xcode-versionen**
6. **Verifiera kompatibilitet:**
   - Om watchOS är för ny för din Xcode-version: **Uppdatera Xcode**
   - Om watchOS är för gammal: **Uppdatera Watch** (via Watch-appen på iPhone)

#### Para Watch om från början

**VIKTIGT:** Detta tar bort alla data från Watch. Säkerhetskopiera först om nödvändigt.

1. **På iPhone:** Öppna Watch-appen
2. Gå till **Allmänt → Återställ → Ta bort Apple Watch-data**
3. **Bekräfta** att du vill ta bort parningen
4. **Para Watch igen** från början (se Steg 1)
5. **Följ alla steg ovan igen**

#### Kontrollera att iPhone är litad på

1. När du kopplar in iPhone till Mac första gången
2. På iPhone bör du se: **"Lita på denna dator?"**
3. **Tryck "Lita på"**
4. **Ange iPhone-lösenkod** om det frågas
5. Om du missade detta: Koppla ur och koppla in iPhone igen

## Checklista

Följ dessa i ordning och kryssa av när du är klar:

- [ ] Watch är parad med iPhone (kontrollera i Watch-appen på iPhone)
- [ ] Båda enheterna är upplåsta (inte på låsskärmen)
- [ ] Bluetooth är påslagen på iPhone
- [ ] Watch visas i Bluetooth-listan på iPhone
- [ ] iPhone är ansluten till Mac via USB-kabel
- [ ] iPhone är litad på Mac ("Lita på denna dator")
- [ ] Watch är startad och aktiv
- [ ] Xcode är startat om (stängd helt och öppnad igen)
- [ ] Devices and Simulators är öppet (⌘⇧2)
- [ ] Väntat 30 sekunder efter att ha öppnat Devices and Simulators

## Vanliga orsaker

### 1. Watch är inte parad
**Symptom:** Watch visas inte alls i Watch-appen på iPhone
**Lösning:** Para Watch med iPhone (se Steg 1)

### 2. Watch är inte upplåst
**Symptom:** Watch är på låsskärmen
**Lösning:** Lås upp Watch (inte på låsskärmen)

### 3. Bluetooth är avstängt
**Symptom:** Watch visas inte i Bluetooth-listan på iPhone
**Lösning:** Aktivera Bluetooth på iPhone

### 4. Inkompatibel watchOS-version
**Symptom:** Watch är parad men visas inte i Xcode
**Lösning:** Uppdatera Xcode eller Watch (se Steg 8)

### 5. Xcode har inte identifierat Watch än
**Symptom:** Allt ser korrekt ut men Watch visas inte
**Lösning:** Vänta 30-60 sekunder i Devices and Simulators, eller starta om Xcode

## Watch visas i Console men inte i Devices and Simulators

Om Watch visas i Console/Console-appen men inte i Devices and Simulators:

**Detta betyder:**
- ✅ Watch är faktiskt ansluten och identifierad av systemet
- ✅ Watch är parad med iPhone
- ❌ Xcode's Devices and Simulators-fönster visar den inte korrekt

**Lösning: Försök ändå installera Watch-appen:**

### Metod 1: Försök välja Watch i destination-väljaren ändå

1. I Xcode, välj scheme **"RunRunTimer Watch App Watch App"**
2. Klicka på **destination-väljaren** (bredvid play-knappen)
3. **Scrolla genom listan** - Watch kan finnas där ändå, även om den inte visas i Devices and Simulators
4. Leta efter något som:
   - "iPhone Name's Apple Watch"
   - "Apple Watch"
   - Eller bara Watch-modellen (t.ex. "Apple Watch Series 9")
5. Om du hittar Watch, välj den och tryck **⌘R**

### Metod 2: Använd xcodebuild från terminal

Om Watch inte visas i destination-väljaren, kan du försöka installera via terminal:

```bash
cd /Users/katrin/runrun_ios/RunRunTimer

# Lista tillgängliga enheter
xcrun xctrace list devices

# Försök bygga och installera Watch-appen
# (Ersätt med rätt device identifier från listan ovan)
xcodebuild -project RunRunTimer.xcodeproj \
  -scheme "RunRunTimer Watch App Watch App" \
  -destination 'id=WATCH_DEVICE_ID' \
  build install
```

### Metod 3: Installera via iOS-appen

När du installerar iOS-appen, kan Watch-appen installeras automatiskt:

1. I Xcode, välj scheme **"RunRunTimer"** (iOS-appen)
2. Välj din **iPhone** som destination
3. Tryck **⌘R** för att köra
4. När iOS-appen installeras, kan Watch-appen installeras automatiskt om:
   - Watch är parad och upplåst
   - Watch-appen är konfigurerad korrekt i projektet

### Metod 4: Uppdatera Devices and Simulators

Ibland behöver Devices and Simulators uppdateras:

1. I Xcode: **Window → Devices and Simulators** (⌘⇧2)
2. Tryck **⌘R** för att uppdatera (eller stäng och öppna fönstret igen)
3. Välj din iPhone
4. **Vänta 30-60 sekunder**
5. Scrolla ned i höger panel
6. Watch kan nu visas

### Metod 5: Kontrollera Console för Watch-identifierare

1. Öppna **Console-appen** på Mac (Applications → Utilities → Console)
2. Sök efter "Apple Watch" eller "watch"
3. Du kan se Watch's identifier eller namn
4. Använd denna information för att identifiera Watch i Xcode

## När Watch visas i Devices and Simulators

När Watch äntligen visas, kommer den att:
- Antingen visas som en separat enhet i vänster lista under iPhone
- Eller visas i höger panel när du väljer iPhone

Då kan du:
1. Välja Watch som destination i Xcode
2. Installera Watch-appen (scheme "RunRunTimer Watch App Watch App" → Watch → ⌘R)

## Ytterligare hjälp

Om inget av ovanstående fungerar:
- Kontrollera Apple Developer-forum
- Kontrollera att din Watch-modell stöds av din Xcode-version
- Överväg att testa med en annan Watch om möjligt

---

**Lycka till!** Detta problem är vanligt och oftast lösbart med ovanstående steg. ⌚


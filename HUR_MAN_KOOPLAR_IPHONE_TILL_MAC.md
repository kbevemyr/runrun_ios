# Hur man kopplar iPhone till Mac för utveckling

## Steg 1: Fysisk anslutning

### Använd USB-kabel
1. **Anslut iPhone till Mac** med en USB-kabel (Lightning eller USB-C beroende på din iPhone-modell)
2. Om du använder en USB-C till Lightning-adapter, anslut den först

### Alternativ: Trådlös anslutning (för senare)
- När du har anslutit en gång via kabel, kan du aktivera trådlös anslutning
- Detta kräver att båda enheterna är på samma Wi-Fi-nätverk

---

## Steg 2: Lita på datorn på iPhone

När du ansluter iPhone första gången:

1. **iPhone visar en dialog:** "Lita på denna dator?"
2. **Tryck "Lita på"** på iPhone
3. **Ange din iPhone-lösenkod** om det frågas
4. **Bekräfta** att du vill lita på datorn

**OBS:** Om du inte ser dialogen:
- Kontrollera att kabeln är korrekt ansluten
- Prova en annan USB-port på Mac
- Prova en annan kabel om möjligt

---

## Steg 3: Öppna Xcode

1. **Öppna Xcode** på din Mac
2. **Anslut iPhone** (om du inte redan gjort det)
3. **Vänta några sekunder** medan Xcode identifierar enheten

---

## Steg 4: Välj iPhone som destination

1. I Xcode, klicka på **scheme-väljaren** (bredvid play-knappen)
2. Du bör se din iPhone i listan under "iOS Device" eller "Connected Devices"
3. **Välj din iPhone** som destination

**Om du inte ser din iPhone:**
- Kontrollera att iPhone är upplåst
- Kontrollera att du har litat på datorn (se Steg 2)
- Prova att koppla ur och koppla in kabeln igen
- Starta om Xcode

---

## Steg 5: Konfigurera utvecklarcertifikat (första gången)

Första gången du kör en app på din iPhone:

### Alternativ A: Automatisk signering (Rekommenderat)
1. I Xcode, välj projektet i Project Navigator (blå ikon)
2. Välj **"RunRunTimer"** target
3. Gå till **"Signing & Capabilities"**-fliken
4. Kryssa i **"Automatically manage signing"**
5. Välj ditt **Team** (din Apple ID)
6. Xcode skapar automatiskt ett utvecklarcertifikat

### Alternativ B: Manuell signering
Om automatisk signering inte fungerar:
1. Kryssa ur "Automatically manage signing"
2. Välj ditt Team
3. Välj eller skapa ett Provisioning Profile

---

## Steg 6: Konfigurera iPhone för utveckling

**VIKTIGT:** Apple ID visas INTE i VPN & Enhetshantering förrän du försöker köra en app från Xcode första gången.

### Så här får du Apple ID att visas:

1. **Försök köra appen från Xcode först** (se Steg 7 nedan)
2. När Xcode försöker installera appen på iPhone, kommer ett felmeddelande eller en varning
3. **Då** kommer din Apple ID att visas i VPN & Enhetshantering
4. Gå till **Inställningar → Allmänt → VPN & Enhetshantering**
   - (På äldre iOS: **Inställningar → Allmänt → Profil & Enhetshantering**)
5. Du bör nu se din Apple ID under "Developer App"
6. **Tryck på din Apple ID**
7. **Tryck "Lita på [din Apple ID]"**
8. **Bekräfta** att du vill lita på utvecklaren
9. Gå tillbaka till Xcode och försök köra appen igen (⌘R)

**OBS:** 
- Om du inte ser Apple ID, försök köra appen från Xcode först
- Detta steg krävs första gången du kör en app från Xcode
- Efter att du litat på utvecklaren, fungerar det automatiskt framöver

---

## Steg 7: Kör appen på iPhone

1. I Xcode, välj din **iPhone** som destination
2. Välj rätt **scheme** (t.ex. "RunRunTimer")
3. **Tryck ⌘R** eller klicka på play-knappen

**Första gången kan något av följande hända:**

**Scenario A: Appen körs direkt**
- Xcode bygger appen och installerar den på iPhone
- Appen startar automatiskt
- Perfekt! Du är klar.

**Scenario B: Du får ett signeringsfel eller varning**
- Xcode kan visa ett fel om signering eller att du behöver lita på utvecklaren
- **Gå till iPhone:** **Inställningar → Allmänt → VPN & Enhetshantering**
- Nu bör din Apple ID visas där (efter att Xcode försökt installera appen)
- **Tryck på din Apple ID** → **"Lita på [din Apple ID]"**
- **Gå tillbaka till Xcode** och tryck ⌘R igen
- Nu fungerar det!

**Scenario C: "Untrusted Developer" på iPhone**
- Om appen startar men visar "Untrusted Developer"
- **Gå till iPhone:** **Inställningar → Allmänt → VPN & Enhetshantering**
- Tryck på din Apple ID → "Lita på [din Apple ID]"
- Öppna appen igen på iPhone

**Efter första gången:**
- Allt fungerar automatiskt
- Du behöver inte lita på utvecklaren igen

---

## Felsökning

### iPhone visas inte i Xcode

**Lösning 1: Kontrollera anslutning**
- Koppla ur och koppla in USB-kabeln
- Prova en annan USB-port
- Prova en annan kabel

**Lösning 2: Kontrollera att du litat på datorn**
- På iPhone: Kontrollera att du har tryckt "Lita på" när dialogen visades
- Om du missade det: Koppla ur och koppla in kabeln igen

**Lösning 3: Kontrollera Xcode**
- Stäng och öppna Xcode igen
- Kontrollera att du har senaste versionen av Xcode
- Kontrollera **Window → Devices and Simulators** (⌘⇧2) för att se alla anslutna enheter

**Lösning 4: Kontrollera iOS-version**
- Din iPhone måste ha en iOS-version som stöds av din Xcode-version
- Kontrollera kompatibilitet: [Apple Developer - Xcode Requirements](https://developer.apple.com/xcode/)

### "Untrusted Developer" på iPhone

**Lösning:**
1. Gå till **Inställningar → Allmänt → VPN & Enhetshantering**
2. Om du inte ser din Apple ID:
   - Försök köra appen från Xcode först (⌘R)
   - Vänta tills Xcode försöker installera appen
   - Då kommer Apple ID att visas i VPN & Enhetshantering
3. Tryck på din Apple ID under "Developer App"
4. Tryck **"Lita på [din Apple ID]"**
5. Bekräfta
6. Öppna appen igen på iPhone

### Apple ID visas inte i VPN & Enhetshantering

**Detta är normalt!** Apple ID visas först när du försöker köra en app från Xcode.

**Lösning:**
1. **Försök köra appen från Xcode först** (⌘R)
2. Även om det ger ett fel, kommer Apple ID att visas i VPN & Enhetshantering
3. Gå till **Inställningar → Allmänt → VPN & Enhetshantering**
4. Nu bör din Apple ID visas
5. Lita på utvecklaren
6. Försök köra appen igen från Xcode

### "Could not launch" eller signeringsfel

**Lösning 1: Automatisk signering**
1. I Xcode: Projekt → Target → Signing & Capabilities
2. Kryssa i "Automatically manage signing"
3. Välj ditt Team
4. Xcode fixar signeringen automatiskt

**Lösning 2: Rensa och bygg igen**
```bash
# I Xcode: Product → Clean Build Folder (⌘⇧K)
# Sedan: Product → Build (⌘B)
```

**Lösning 3: Kontrollera Bundle Identifier**
- Kontrollera att Bundle Identifier är unikt
- Ändra om nödvändigt (t.ex. lägg till ditt namn: `com.runrun.yourname`)

### iPhone kopplas bort under byggning

**Lösning:**
- Använd en original Apple-kabel (eller certifierad tredjepartskabel)
- Undvik USB-hubbar, anslut direkt till Mac
- Kontrollera att kabeln inte är skadad

---

## Trådlös anslutning (efter första anslutningen)

När du har anslutit iPhone via kabel första gången:

1. **Anslut iPhone via kabel** (en sista gång)
2. I Xcode: **Window → Devices and Simulators** (⌘⇧2)
3. Välj din iPhone
4. Kryssa i **"Connect via network"**
5. Vänta tills en Wi-Fi-ikon visas bredvid enheten
6. Nu kan du koppla ur kabeln och använda trådlös anslutning

**Förutsättningar:**
- Båda enheterna måste vara på samma Wi-Fi-nätverk
- iPhone måste vara upplåst
- Trådlös anslutning kan vara långsammare än kabel

---

## För Apple Watch

Om du vill testa Watch-appen på riktig Apple Watch, se den detaljerade guiden:
**`HUR_MAN_INSTALLERAR_WATCH_APP.md`**

### Snabb sammanfattning:

**Förutsättningar:**
1. iPhone måste vara ansluten till Mac (se ovan)
2. iOS-appen måste vara installerad på iPhone först
3. Apple Watch måste vara parad med iPhone
4. Båda enheterna måste vara upplåsta

**Snabba steg:**
1. Installera iOS-appen först (scheme "RunRunTimer" → iPhone → ⌘R)
2. Välj scheme **"RunRunTimer Watch App Watch App"**
3. Välj din **Apple Watch** som destination (visas under iPhone)
4. Tryck **⌘R** för att köra
5. Watch-appen installeras via iPhone och startar på Watch

**OBS:** 
- Watch-appen måste installeras via iPhone (kan inte installeras direkt på Watch)
- Se `HUR_MAN_INSTALLERAR_WATCH_APP.md` för detaljerade instruktioner och felsökning

---

## Tips och tricks

### Snabbare byggning
- Använd **kabel** istället för trådlös anslutning för snabbare överföring
- Stäng andra applikationer för bättre prestanda

### Debugging
- Du kan sätta **breakpoints** och debugga direkt på iPhone
- Console-utskrifter visas i Xcode
- Du kan inspektera variabler och köra kod steg för steg

### Testa på flera enheter
- Du kan ha flera iPhones anslutna samtidigt
- Välj vilken enhet du vill köra på i destination-väljaren
- Användbart för att testa på olika iOS-versioner

### Automatisk installation
- När du bygger och kör, installeras appen automatiskt på iPhone
- Du behöver inte installera manuellt via App Store
- Appen försvinner när du tar bort den från Xcode (eller när certifikatet går ut)

---

## Säkerhet och integritet

### Vad betyder "Lita på utvecklaren"?
- Detta ger Xcode behörighet att installera och köra appar på din iPhone
- Det är säkert när du använder din egen Apple ID
- Du kan alltid ta bort förtroendet i Inställningar

### Ta bort förtroende
Om du vill ta bort förtroendet senare:
1. På iPhone: **Inställningar → Allmänt → VPN & Enhetshantering**
2. Tryck på din Apple ID
3. Tryck **"Ta bort förtroende"**

---

## Ytterligare resurser

- [Apple Developer - Running Your App on Devices](https://developer.apple.com/documentation/xcode/running-your-app-on-devices)
- [Apple Developer - Signing Your App](https://developer.apple.com/documentation/xcode/signing-your-app)

---

**Lycka till med utvecklingen!** 📱💻


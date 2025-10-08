# RunRun - Snabbguide

## 🎯 Vad är nytt?

RunRun har nu ett komplett system för att spara, hantera och dela dina workouts!

## 🚀 Snabbstart

### 1. Skapa och Spara en Workout

**Steg för steg:**
1. Öppna appen
2. Välj **Editor**-tabben (penna-ikon)
3. Skriv din workout, t.ex: `P10 (x3 W60 R20)`
4. Tryck **Förhandsvisa** - du ser nu hur workout ser ut
5. Tryck **Save** (pil ner-ikon)
6. Ange en titel, t.ex: "HIIT Session"
7. (Valfritt) Lägg till anteckningar
8. Tryck **Save**
9. ✅ Din workout är nu sparad!

### 2. Köra en Sparad Workout

**Steg för steg:**
1. Välj **Library**-tabben (lista-ikon)
2. Hitta din workout i listan
3. Tryck på **play-knappen** ▶️
4. Workout startar direkt!
5. Använd kontrollerna:
   - ▶️/⏸ för att starta/pausa
   - ⏮ för att gå tillbaka
   - ⏭ för att hoppa framåt
   - 🔄 för att starta om

### 3. Dela en Workout med Vänner

**Steg för steg:**
1. Gå till **Library**
2. Hitta workout du vill dela
3. Tryck **Share**
4. Välj hur du vill dela:
   - **AirDrop** - skicka direkt till en iPhone/iPad i närheten
   - **iMessage** - skicka till en vän
   - **Email** - maila workoutfilen
   - **Spara till Filer** - spara för senare
5. ✅ Mottagaren får en `.runrun`-fil

### 4. Ta Emot och Importera en Workout

**Från AirDrop/Mail/Meddelande:**
1. Ta emot `.runrun`-filen
2. Öppna filen
3. Välj "RunRun" eller "Kopiera till RunRun"
4. Workout importeras automatiskt!

**Manuell import:**
1. Gå till **Library**
2. Tryck på **import-knappen** ⬇️ (överst till höger)
3. Välj **Import from File**
4. Välj `.runrun`-filen
5. ✅ Workout är nu i ditt bibliotek!

### 5. Importera från Text

Om någon skickar dig bara texten (t.ex. via SMS):
1. Kopiera texten (t.ex. `P10 (x3 W60 R20)`)
2. Gå till **Library**
3. Tryck **import-knappen** ⬇️
4. Välj **Import from Text**
5. Klistra in texten
6. Ange en titel
7. Tryck **Import**
8. ✅ Klar!

## 📝 Exempel på Workouts att Testa

### HIIT Nybörjare
```
P10 (x5 W30 R30)
```
- 10 sek förberedelse
- 5 intervaller: 30 sek arbete, 30 sek vila

### Tabata
```
P10 (x8 W20 R10)
```
- 8 intervaller: 20 sek arbete, 10 sek vila
- Klassisk Tabata-struktur

### VO2 Max Intervals
```
P10 (x4 W3m@VO2 R2m)
```
- 4 intervaller: 3 min arbete (VO2-intensitet), 2 min vila

### Komplex Pyramid
```
P15 (x3 W1m R30 W2m R30 W3m R2m@set-rest)
```
- 3 set med pyramid-struktur
- 2 min vila mellan seten

## 🎨 Tips & Tricks

### Organisera dina Workouts
- Använd beskrivande titlar: "Måndag HIIT", "Lång VO2", etc.
- Lägg till anteckningar för att komma ihåg intensitet eller mål

### Detaljer i Biblioteket
- Tryck **Details** på en workout för att se:
  - När den skapades
  - Vem som skapade den
  - Unikt ID

### Hantera Lagring
- Ta bort gamla workouts du inte använder längre
- Uppdatera en workout genom att spara med samma titel

### Dela Smart
- **AirDrop** är snabbast mellan Apple-enheter
- **iMessage** för att skicka till vänner
- **Email** för att spara som backup

## 🔧 Programspråk-referens

### Grundläggande
- `W60` = Work 60 sekunder
- `R30` = Rest 30 sekunder
- `P10` = Prepare 10 sekunder

### Tidsformat
- `60` eller `60s` = 60 sekunder
- `2m` = 2 minuter
- `1m30` = 1 minut 30 sekunder

### Repetitioner
- `(x5 W30 R20)` = Upprepa 5 gånger

### Nästlade Repetitioner
- `(x3 (x2 W20 R10) R60)` = 3 set, varje set har 2 intervaller

### Etiketter
- `W60@VO2` = Work 60 sek med etikett "VO2"
- `R2m@set-rest` = Rest 2 min med etikett "set-rest"

## ❓ Vanliga Frågor

### Var sparas mina workouts?
Lokalt på din enhet med UserDefaults. De försvinner inte om du stänger appen.

### Kan jag synka mellan enheter?
Inte än - men du kan dela workouts mellan enheter via AirDrop!

### Vad är en .runrun-fil?
En JSON-fil som innehåller all information om din workout (program, titel, anteckningar, etc.)

### Kan jag redigera en sparad workout?
Inte direkt - men du kan:
1. Öppna den i Editor
2. Ändra programmet
3. Spara med samma titel (uppdaterar den)

### Tar workouts mycket plats?
Nej! Varje workout är bara några hundra bytes. Du kan ha hundratals utan problem.

## 🐛 Felsökning

### "Failed to load workouts"
- Starta om appen
- Kontrollera att appen har tillgång till lagring

### "Invalid program"
- Kontrollera syntax (använd **Validera** i Editor)
- Se till att parenteser är balanserade
- Använd endast tillåtna tecken (W, R, P, x, m, s, @, parenteser, siffror)

### Import fungerar inte
- Kontrollera att filen är en giltig `.runrun`-fil (JSON)
- Försök importera från text istället

## 📱 Kontakt & Support

Om du har problem eller förslag:
- Kolla WORKOUT_STORAGE_GUIDE.md för teknisk information
- Se de inbyggda exemplen i Editor-preview

---

**Ha kul med dina workouts! 🏃‍♀️💪**


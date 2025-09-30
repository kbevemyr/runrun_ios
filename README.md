# RunRun - Interval Timer App

En Swift-implementation av interval timer-appen för iOS och watchOS.

## Struktur

```
RunRunCore/          # Kärnbibliotek med parser, engine, modeller
RunRuniOS/           # iOS SwiftUI-stubbar (Editor, Preview, Run)
RunRunWatch/         # watchOS SwiftUI-stubbar (Run)
TestApps/            # Test-appar för iOS och watchOS
```

## Bygginstruktioner

### 1. Bygg kärnbiblioteket
```bash
cd RunRunCore
swift build
```

### 2. Bygg iOS-paketet
```bash
cd RunRuniOS
swift build
```

### 3. Bygg watchOS-paketet
```bash
cd RunRunWatch
swift build
```

### 4. Testa med test-appar

#### iOS Test App
```bash
cd TestApps/iOS
swift run
```

#### watchOS Test App
```bash
cd TestApps/watchOS
swift run
```

## Programmeringsspråk

Appen använder ett enkelt programspråk för att definiera träningspass:

- `P<duration>` - Förberedelse (≥0 sekunder)
- `W<duration>` - Arbete (>0 sekunder)  
- `R<duration>` - Vila (≥0 sekunder)
- `x<int>` - Upprepa nästa enhet N gånger
- `( ... )` - Grupp
- `@<label>` - Etikett för föregående enhet/grupp

### Duration-format
- Heltal = sekunder (`90`)
- `Ns`, `Nm`, `Nh` med kombinationer (`1h30m`, `2m15s`)
- Noll (`0` eller `0s`) tillåten endast för `P` och `R`

### Exempel
```
P10 (x3 (x3 W70@VO2 R20) R2m@set-rest)
(x4 (W2m@tempo R20 W100 R20 W80 R20 W60 R20 W40) R55)
P15 (x6 (W30s@Rest R15s))@sprints
```

## API

### Core
- `WorkoutBuilder` - Bygger Workout från programsträng
- `Engine` - Kör timer med status-uppdateringar
- `Status` - Aktuell status med progress och nästa segment
- `Notifier` - Protokoll för haptik/ljud-notifieringar

### iOS
- `EditorView` - Textredigerare med validering
- `PreviewView` - Förhandsvisning av segment
- `RunView` - Timer med kontroller
- `RunViewModel` - ViewModel för timer-logik

### watchOS
- `WatchRunView` - Kompakt timer-vy för klockan
- `WatchRunViewModel` - ViewModel för watchOS

## Testning

1. **Parser-test**: Använd test-apparna för att testa olika programsträngar
2. **Timer-test**: Starta timers och verifiera att status uppdateras korrekt
3. **Haptik-test**: Testa på riktiga enheter för haptik-feedback
4. **Import/Export**: Testa JSON-format för sparning/laddning

## Nästa steg

- Lägg till Xcode-projekt för riktiga iOS/watchOS-appar
- Implementera iCloud-synkronisering
- Lägg till fler notifieringar (pre-alerts)
- Förbättra UI med animationer och färger
- Lägg till VoiceOver-stöd

# ⌚ WatchOS Fix Guide

## Problem
```
The package product 'RunRunCore' requires minimum platform version 13.0 for the iOS platform, but this target supports 12.0
```

Detta händer eftersom `RunRunWatch` är ett **watchOS-paket** men Xcode försöker kompilera det för **iOS**.

## ✅ Lösning

### Alternativ 1: Ta bort RunRunWatch från iOS-projektet

Om du bara vill ha iOS-appen:

1. **Öppna Xcode-projektet**
2. **Välj projektet** (blå ikon)
3. **Package Dependencies** tab
4. **Ta bort RunRunWatch** (om det finns)
5. **Behåll endast:**
   - RunRunCore
   - RunRuniOS

### Alternativ 2: Skapa separat watchOS-projekt

Om du vill ha Apple Watch-app:

1. **Skapa nytt Xcode-projekt**
2. **Välj watchOS → App**
3. **Lägg till RunRunCore och RunRunWatch** som dependencies
4. **Sätt watchOS Deployment Target till 6.0**

### Alternativ 3: Uppdatera iOS Deployment Target

Om du vill behålla allt i samma projekt:

1. **Välj RunRunApp target**
2. **Build Settings** tab
3. **Sök på "Deployment Target"**
4. **Sätt iOS Deployment Target till 13.0**

## 🎯 Rekommendation

**För iOS-app:** Använd bara `RunRunCore` + `RunRuniOS`
**För Apple Watch:** Skapa separat watchOS-projekt

## 📱 Verifiering

Efter fix borde du ha:
- ✅ iOS-app fungerar med RunRunCore + RunRuniOS
- ✅ Inga plattformsversion-fel
- ✅ EditorView och RunView fungerar

## 🚨 Om du fortfarande får fel

**Rensa allt:**
```bash
cd /Users/katrin/runrun_ios
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

**Öppna Xcode igen och uppdatera dependencies.**

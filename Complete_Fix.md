# 🔧 Komplett Fix för iOS 12.0 Problem

## Problem
```
The package product 'RunRunCore' requires minimum platform version 13.0 for the iOS platform, but this target supports 12.0
```

Trots att deployment target är iOS 17.0, får du fortfarande detta fel.

## ✅ Komplett lösning

### 1. Stäng Xcode helt
```bash
# Stäng Xcode om det är öppet
```

### 2. Rensa ALLA caches
```bash
cd /Users/katrin/runrun_ios
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf RunRunApp/RunRunApp/RunRunApp.xcodeproj/project.xcworkspace/xcshareddata
rm -rf RunRunApp/RunRunApp/RunRunApp.xcodeproj/project.xcworkspace/xcuserdata
```

### 3. Ta bort Package.resolved
```bash
find . -name "Package.resolved" -delete
```

### 4. Öppna Xcode igen
```bash
open RunRunApp/RunRunApp/RunRunApp.xcodeproj
```

### 5. Kontrollera alla targets
1. **Välj projektet** (blå ikon)
2. **Välj RunRunApp target**
3. **Build Settings** tab
4. **Sök på "Deployment Target"**
5. **Kontrollera att iOS Deployment Target är 13.0 eller högre**

### 6. Uppdatera Package Dependencies
1. **Package Dependencies** tab
2. **Ta bort alla paket** (RunRunCore, RunRuniOS, RunRunWatch)
3. **Lägg till igen:**
   - Klicka "+" → Add Local...
   - Välj `../RunRunCore`
   - Klicka "+" → Add Local...
   - Välj `../RunRuniOS`
4. **Klicka "Update to Latest Package Versions"**

### 7. Clean Build
1. **Product → Clean Build Folder** (Cmd+Shift+K)
2. **Product → Build** (Cmd+B)

## 🚨 Om det fortfarande inte fungerar

### Alternativ 1: Skapa nytt projekt
```bash
cd /Users/katrin/runrun_ios
mkdir NewRunRunApp
cd NewRunRunApp
# Skapa nytt Xcode-projekt här
```

### Alternativ 2: Använd terminal-versionen
```bash
cd /Users/katrin/runrun_ios/RunRunApp
swift run
```

## 📱 Verifiering

Efter fix borde du ha:
- ✅ Inga "minimum platform version" fel
- ✅ iOS-app fungerar med RunRunCore + RunRuniOS
- ✅ EditorView och RunView fungerar

## 🔍 Debug info

Om du fortfarande får fel, kontrollera:
- Alla targets har iOS 13.0+ deployment target
- Inga gamla Package.resolved filer finns
- Xcode cache är rensad
- Paketen är uppdaterade till senaste version

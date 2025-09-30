# 🚀 Snabb Xcode Fix

## Problem
Xcode använder fortfarande gamla versionen av RunRunCore (iOS 16.0) trots att vi sänkte till iOS 13.0.

## ✅ Steg-för-steg lösning

### 1. Stäng Xcode helt
```bash
# Stäng Xcode om det är öppet
```

### 2. Rensa alla caches
```bash
cd /Users/katrin/runrun_ios
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf RunRunApp/RunRunApp/RunRunApp.xcodeproj/project.xcworkspace/xcshareddata
```

### 3. Öppna Xcode igen
```bash
open RunRunApp/RunRunApp/RunRunApp.xcodeproj
```

### 4. Uppdatera Package Dependencies
1. **Välj projektet** (blå ikon)
2. **Package Dependencies** tab
3. **Klicka "Update to Latest Package Versions"** (uppdaterings-ikon)
4. **Vänta** tills alla paket är uppdaterade

### 5. Kontrollera Deployment Target
1. **Välj ditt app target** (RunRunApp)
2. **Build Settings** tab
3. **Sök på "Deployment Target"**
4. **Sätt iOS Deployment Target till 13.0**

### 6. Clean Build
1. **Product → Clean Build Folder** (Cmd+Shift+K)
2. **Product → Build** (Cmd+B)

## 🔍 Verifiera att det fungerar

Kontrollera att:
- ✅ Inga "minimum platform version" fel
- ✅ Alla paket visar rätt versioner
- ✅ Projektet bygger utan fel

## 🚨 Om det fortfarande inte fungerar

**Alternativ 1: Ta bort och lägg till igen**
1. Ta bort RunRunCore från Package Dependencies
2. Lägg till igen med "Add Local..." → välj `../RunRunCore`

**Alternativ 2: Använd terminal-versionen**
```bash
cd /Users/katrin/runrun_ios/RunRunApp
swift run
```

## 📱 Resultat

Efter detta borde du ha:
- ✅ Fungerande iOS-app med RunRunCore
- ✅ EditorView och RunView fungerar
- ✅ Inga plattformsversion-fel

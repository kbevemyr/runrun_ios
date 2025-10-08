#!/bin/bash

# Script för att fixa Xcode build-problem med WorkoutStorage
# Kör detta om du får "Cannot find 'WorkoutStorage' in scope" fel

echo "🔧 Fixar Xcode build-problem..."
echo ""

# Steg 1: Rensa Swift Package Manager caches
echo "📦 Rensar Swift Package Manager caches..."
cd /Users/katrin/runrun_ios/RunRunApp/RunRunApp
rm -rf .build
echo "✅ SPM caches rensade"

# Steg 2: Rensa Derived Data för RunRun-projekt
echo "🗑️  Rensar Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*RunRun*
echo "✅ Derived Data rensat"

# Steg 3: Verifiera att paketen bygger korrekt
echo ""
echo "🔍 Verifierar att RunRunCore bygger..."
cd /Users/katrin/runrun_ios/RunRunCore
if swift build > /dev/null 2>&1; then
    echo "✅ RunRunCore bygger korrekt"
else
    echo "❌ RunRunCore bygger INTE korrekt"
    exit 1
fi

echo "🔍 Verifierar att RunRuniOS bygger..."
cd /Users/katrin/runrun_ios/RunRuniOS
if swift build > /dev/null 2>&1; then
    echo "✅ RunRuniOS bygger korrekt"
else
    echo "❌ RunRuniOS bygger INTE korrekt"
    exit 1
fi

echo ""
echo "✨ Allt ser bra ut från kommandoraden!"
echo ""
echo "📝 Nästa steg i Xcode:"
echo "  1. Öppna RunRunApp.xcodeproj"
echo "  2. File → Packages → Reset Package Caches"
echo "  3. Product → Clean Build Folder (Shift+Cmd+K)"
echo "  4. Product → Build (Cmd+B)"
echo ""
echo "🎉 Klart! Försök bygga i Xcode nu."


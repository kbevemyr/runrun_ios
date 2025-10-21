//
//  RunRunTimer_Watch_AppApp.swift
//  RunRunTimer Watch App
//
//  Created by Katrin Boberg Bevemyr on 15/10/2025.
//


import SwiftUI
import RunRunCore

@main
struct RunRunTimer_Watch_App: App {
    var body: some Scene {
        WindowGroup {
            // Byt gärna till en vy som kommer från ditt runrunWatch-paket
            //ContentViewWatch()
            ContentView()
        }
    }
}

struct ContentViewWatch: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("RunRunTimer")
                .font(.headline)
            Text("watchOS 10 · använder runruncore + runrunWatch")
                .font(.footnote)
                .foregroundStyle(.secondary)
            // Exempel: Anropa något från runruncore / runrunWatch här
        }
    }
}


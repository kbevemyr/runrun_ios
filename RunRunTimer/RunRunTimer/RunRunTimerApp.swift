//
//  RunRunTimerApp.swift
//  RunRunTimer
//
//  Created by Katrin Boberg Bevemyr on 15/10/2025.
//

import SwiftUI
import RunRunCore

@main
struct RunRunTimerApp: App {
    var body: some Scene {
        WindowGroup {
            // Byt gärna till en vy som kommer från ditt runrunIOS-paket
            //ContentViewIOS()
            ContentView()
        }
    }
}

struct ContentViewIOS: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("RunRunTimer (iOS)")
                .font(.title)
                .bold()
            Text("iOS 17 · använder runruncore + runrunIOS")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            // Exempel: Anropa något från runruncore / runrunIOS här
            // t.ex. TimerView() om den finns i runrunIOS
        }
        .padding()
    }
}


import Foundation
import RunRunCore
import RunRunWatch

#if os(watchOS)
import SwiftUI

@main
struct RunRunWatchTestApp: App {
    init() {
        // Aktivera WatchConnectivity vid start
        _ = WatchConnectivityManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            WatchWorkoutListView()
        }
    }
}

#else
// watchOS test app - kör på Apple Watch simulator eller enhet
#endif

import SwiftUI
import RunRunCore

#if os(iOS)

/// Huvudvy för RunRun appen med tabs för Library och Editor
public struct MainAppView: View {
	@State private var selectedTab = 0
	@StateObject private var connectivity = WatchConnectivityManager.shared
	
	public init() {}
	
	public var body: some View {
		TabView(selection: $selectedTab) {
			WorkoutLibraryView()
				.tabItem {
					Label("Library", systemImage: "list.bullet")
				}
				.tag(0)
            
			LibraryView()
				.tabItem {
					Label("ClaudLib", systemImage: "list.bullet")
				}
				.tag(1)
			
			EditorView(isTabMode: true, onWorkoutSaved: {
				// Byt till ClaudLib-tabben när workout är sparad
				selectedTab = 1
			})
				.tabItem {
					Label("Add", systemImage: "plus")
				}
				.tag(2)
			
			WatchSyncView()
				.tabItem {
					Label("Watch", systemImage: "applewatch")
				}
				.tag(3)
		}
		.onAppear {
			// Aktivera WatchConnectivity vid start
			print("WatchConnectivity aktiverad")
		}
	}
}

#if DEBUG
#Preview {
	MainAppView()
}
#endif

#endif


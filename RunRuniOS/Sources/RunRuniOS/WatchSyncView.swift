import SwiftUI
import RunRunCore

#if os(iOS)

/// Vy för att hantera synkronisering med Apple Watch
public struct WatchSyncView: View {
	@StateObject private var viewModel = WatchSyncViewModel()
	
	public init() {}
	
	public var body: some View {
		NavigationView {
			List {
				Section("Watch Status") {
					statusRow(title: "Parad", value: viewModel.isPaired)
					statusRow(title: "App installerad", value: viewModel.isWatchAppInstalled)
					statusRow(title: "Nåbar", value: viewModel.isReachable)
				}
				
				Section("Synkronisering") {
					HStack {
						VStack(alignment: .leading) {
							Text("Synkade workouts")
								.font(.headline)
							Text("\(viewModel.workoutCount) workouts i biblioteket")
								.font(.caption)
								.foregroundColor(.secondary)
						}
						Spacer()
						if viewModel.isSyncing {
							ProgressView()
						}
					}
					
					Button {
						viewModel.syncToWatch()
					} label: {
						Label("Synka till Watch", systemImage: "arrow.down.circle")
					}
					.disabled(!viewModel.canSync || viewModel.isSyncing)
					
					Button {
						viewModel.requestFromWatch()
					} label: {
						Label("Hämta från Watch", systemImage: "arrow.up.circle")
					}
					.disabled(!viewModel.canSync || viewModel.isSyncing)
				}
				
				Section("Information") {
					VStack(alignment: .leading, spacing: 8) {
						Text("Om Watch-synkronisering")
							.font(.headline)
						Text("Dina workouts synkas automatiskt mellan iPhone och Apple Watch. Du kan skapa workouts i iPhone-appen och köra dem på din Apple Watch.")
							.font(.caption)
							.foregroundColor(.secondary)
					}
					.padding(.vertical, 4)
				}
			}
			.navigationTitle("Apple Watch")
			.alert("Synkronisering", isPresented: $viewModel.showingAlert) {
				Button("OK", role: .cancel) {}
			} message: {
				Text(viewModel.alertMessage)
			}
		}
		.onAppear {
			viewModel.updateStatus()
		}
	}
	
	private func statusRow(title: String, value: Bool) -> some View {
		HStack {
			Text(title)
			Spacer()
			Image(systemName: value ? "checkmark.circle.fill" : "xmark.circle.fill")
				.foregroundColor(value ? .green : .red)
			Text(value ? "Ja" : "Nej")
				.foregroundColor(.secondary)
		}
	}
}

// MARK: - ViewModel

@MainActor
final class WatchSyncViewModel: ObservableObject {
	@Published var isPaired = false
	@Published var isWatchAppInstalled = false
	@Published var isReachable = false
	@Published var workoutCount = 0
	@Published var isSyncing = false
	@Published var showingAlert = false
	@Published var alertMessage = ""
	
	private let connectivity = WatchConnectivityManager.shared
	private let storage = WorkoutStorage()
	
	var canSync: Bool {
		isPaired && isWatchAppInstalled
	}
	
	init() {
		// Observera connectivity-ändringar
		connectivity.objectWillChange.sink { [weak self] _ in
			self?.updateStatus()
		}
		.store(in: &cancellables)
	}
	
	private var cancellables = Set<AnyCancellable>()
	
	func updateStatus() {
		isPaired = connectivity.isPaired
		isWatchAppInstalled = connectivity.isWatchAppInstalled
		isReachable = connectivity.isReachable
		
		do {
			workoutCount = try storage.loadAll().count
		} catch {
			workoutCount = 0
		}
	}
	
	func syncToWatch() {
		guard canSync else {
			alertMessage = "Watch är inte tillgänglig. Kontrollera att Apple Watch är parad och appen är installerad."
			showingAlert = true
			return
		}
		
		isSyncing = true
		storage.pushToWatch()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
			self?.isSyncing = false
			self?.alertMessage = "Workouts skickade till Apple Watch!"
			self?.showingAlert = true
		}
	}
	
	func requestFromWatch() {
		guard canSync else {
			alertMessage = "Watch är inte tillgänglig."
			showingAlert = true
			return
		}
		
		isSyncing = true
		storage.requestSyncFromWatch()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
			self?.isSyncing = false
			self?.updateStatus()
			self?.alertMessage = "Hämtade workouts från Apple Watch!"
			self?.showingAlert = true
		}
	}
}

// Import Combine for AnyCancellable
import Combine

#if DEBUG
#Preview {
	WatchSyncView()
}
#endif

#endif


import Foundation
#if os(iOS) || os(watchOS)
import WatchConnectivity

/// Hanterar kommunikation mellan iOS och watchOS via WatchConnectivity
public final class WatchConnectivityManager: NSObject, ObservableObject {
	public static let shared = WatchConnectivityManager()
	
	@Published public private(set) var isReachable = false
	@Published public private(set) var isPaired = false
	@Published public private(set) var isWatchAppInstalled = false
	
	private var session: WCSession?
	private var workoutUpdateHandler: (([WorkoutExport]) -> Void)?
	
	private override init() {
		super.init()
		setupSession()
	}
	
	private func setupSession() {
		guard WCSession.isSupported() else {
			print("WatchConnectivity stöds inte på denna enhet")
			return
		}
		
		session = WCSession.default
		session?.delegate = self
		session?.activate()
	}
	
	// MARK: - Public API
	
	/// Registrera en handler för att ta emot workout-uppdateringar
	public func onWorkoutsReceived(_ handler: @escaping ([WorkoutExport]) -> Void) {
		workoutUpdateHandler = handler
	}
	
	/// Skicka alla workouts till den andra enheten
	public func syncWorkouts(_ workouts: [WorkoutExport]) {
		guard let session = session, session.isReachable else {
			print("Watch är inte nåbar, skickar via context istället")
			sendWorkoutsViaContext(workouts)
			return
		}
		
		sendWorkoutsViaMessage(workouts)
	}
	
	/// Begär alla workouts från den andra enheten
	public func requestWorkouts() {
		guard let session = session, session.isReachable else {
			print("Watch är inte nåbar")
			return
		}
		
		session.sendMessage(["action": "requestWorkouts"], replyHandler: { [weak self] reply in
			if let workoutsData = reply["workouts"] as? Data,
			   let workouts = try? JSONDecoder().decode([WorkoutExport].self, from: workoutsData) {
				DispatchQueue.main.async {
					self?.workoutUpdateHandler?(workouts)
				}
			}
		}, errorHandler: { error in
			print("Fel vid begäran av workouts: \(error.localizedDescription)")
		})
	}
	
	// MARK: - Private Helpers
	
	private func sendWorkoutsViaMessage(_ workouts: [WorkoutExport]) {
		guard let session = session else { return }
		
		do {
			let data = try JSONEncoder().encode(workouts)
			let message: [String: Any] = [
				"action": "syncWorkouts",
				"workouts": data
			]
			
			session.sendMessage(message, replyHandler: { reply in
				print("Workouts skickade via meddelande: \(reply)")
			}, errorHandler: { error in
				print("Fel vid sändning av meddelande: \(error.localizedDescription)")
				// Fallback till context om meddelande misslyckas
				self.sendWorkoutsViaContext(workouts)
			})
		} catch {
			print("Kunde inte koda workouts: \(error.localizedDescription)")
		}
	}
	
	private func sendWorkoutsViaContext(_ workouts: [WorkoutExport]) {
		guard let session = session else { return }
		
		do {
			let data = try JSONEncoder().encode(workouts)
			try session.updateApplicationContext(["workouts": data])
			print("Workouts uppdaterade i application context")
		} catch {
			print("Fel vid uppdatering av context: \(error.localizedDescription)")
		}
	}
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
	public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		DispatchQueue.main.async {
			if let error = error {
				print("WCSession aktivering misslyckades: \(error.localizedDescription)")
				return
			}
			
			print("WCSession aktiverad med state: \(activationState.rawValue)")
			
			#if os(iOS)
			self.isPaired = session.isPaired
			self.isWatchAppInstalled = session.isWatchAppInstalled
			#endif
			
			self.updateReachability(session)
		}
	}
	
	public func sessionReachabilityDidChange(_ session: WCSession) {
		DispatchQueue.main.async {
			self.updateReachability(session)
		}
	}
	
	private func updateReachability(_ session: WCSession) {
		isReachable = session.isReachable
		print("Watch reachability: \(isReachable)")
	}
	
	// MARK: - Ta emot meddelanden
	
	public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
		guard let action = message["action"] as? String else {
			replyHandler(["error": "Ingen action specificerad"])
			return
		}
		
		switch action {
		case "syncWorkouts":
			if let workoutsData = message["workouts"] as? Data,
			   let workouts = try? JSONDecoder().decode([WorkoutExport].self, from: workoutsData) {
				DispatchQueue.main.async {
					self.workoutUpdateHandler?(workouts)
				}
				replyHandler(["status": "success"])
			} else {
				replyHandler(["error": "Kunde inte dekoda workouts"])
			}
			
		case "requestWorkouts":
			// iOS/watchOS svarar med sina workouts
			let storage = WorkoutStorage()
			if let workouts = try? storage.loadAll(),
			   let data = try? JSONEncoder().encode(workouts) {
				replyHandler(["workouts": data])
			} else {
				replyHandler(["workouts": try! JSONEncoder().encode([WorkoutExport]())])
			}
			
		default:
			replyHandler(["error": "Okänd action"])
		}
	}
	
	// MARK: - Ta emot context-uppdateringar
	
	public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
		if let workoutsData = applicationContext["workouts"] as? Data,
		   let workouts = try? JSONDecoder().decode([WorkoutExport].self, from: workoutsData) {
			DispatchQueue.main.async {
				self.workoutUpdateHandler?(workouts)
			}
		}
	}
	
	#if os(iOS)
	public func sessionDidBecomeInactive(_ session: WCSession) {
		print("WCSession blev inaktiv")
	}
	
	public func sessionDidDeactivate(_ session: WCSession) {
		print("WCSession deaktiverad, återaktiverar...")
		session.activate()
	}
	#endif
}

#endif // os(iOS) || os(watchOS)


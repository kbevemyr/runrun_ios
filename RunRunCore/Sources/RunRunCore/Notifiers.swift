import Foundation
#if canImport(AVFoundation)
@preconcurrency import AVFoundation
#endif
#if canImport(AudioToolbox)
import AudioToolbox
#endif
#if canImport(WatchKit)
import WatchKit
#endif

// iOS Notifier med vibration och ljud
#if canImport(AVFoundation) && canImport(UIKit)
import UIKit
public final class iOSNotifier: Notifier {
	private var audioPlayer: AVAudioPlayer?
	
	public init() {
		setupAudio()
	}

	private func setupAudio() {
		// Konfigurera audio session för att spela ljud även när telefonen är i tyst läge
		#if os(iOS)
		do {
			try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
			try AVAudioSession.sharedInstance().setActive(true)
		} catch {
			print("❌ Kunde inte konfigurera AVAudioSession: \(error)")
		}
		#endif
	}
	
	private func playSound(systemSoundID: UInt32) {
		#if os(iOS) && canImport(AudioToolbox)
		AudioServicesPlaySystemSound(systemSoundID)
		#endif
	}

	public func notifyTransition(_ kind: TransitionKind) {
		#if os(iOS)
		// Vibration
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
		
		// Ljud beroende på typ av övergång
		switch kind {
		case .end:
			// Tre pip för slut
			playSound(systemSoundID: 1057) // Tock sound
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
				self?.playSound(systemSoundID: 1057)
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
				self?.playSound(systemSoundID: 1057)
			}
		case .prepareToWork:
			// Högt pip för start av work
			playSound(systemSoundID: 1054) // Higher pitched sound
		case .workToRest:
			// Lägre pip för rest
			playSound(systemSoundID: 1055) // Lower pitched sound
		case .restToWork:
			// Högt pip för nästa work
			playSound(systemSoundID: 1054)
		}
		#endif
	}

	public func notifyPreAlert(secondsBefore: Int) {
		#if os(iOS)
		// Kort vibration för pre-alert
		UIImpactFeedbackGenerator(style: .light).impactOccurred()
		
		// Kort click-ljud
		playSound(systemSoundID: 1104) // Short click
		#endif
	}
}
#endif

// watchOS Notifier med WKInterfaceDevice
#if canImport(WatchKit)
public final class WatchOSNotifier: Notifier {
	public init() {}

	public func notifyTransition(_ kind: TransitionKind) {
		let device = WKInterfaceDevice.current()
		switch kind {
		case .end:
			// 2 långa vibrationer för slut
			device.play(.notification)
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				device.play(.notification)
			}
		default:
			// 1 lång vibration för övergång
			device.play(.notification)
		}
	}

	public func notifyPreAlert(secondsBefore: Int) {
		// Kort vibration för pre-alert
		WKInterfaceDevice.current().play(.click)
	}
}
#endif

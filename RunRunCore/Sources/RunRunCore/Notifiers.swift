import Foundation
#if canImport(AVFoundation)
@preconcurrency import AVFoundation
#endif
#if canImport(WatchKit)
import WatchKit
#endif

// iOS Notifier med enkel vibration
#if canImport(AVFoundation) && canImport(UIKit)
import UIKit
public final class iOSNotifier: Notifier {
	public init() {}

	public func notifyTransition(_ kind: TransitionKind) {
		// Enkel vibration för övergång
		#if os(iOS)
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
		#endif
	}

	public func notifyPreAlert(secondsBefore: Int) {
		// Kort vibration för pre-alert
		#if os(iOS)
		UIImpactFeedbackGenerator(style: .light).impactOccurred()
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

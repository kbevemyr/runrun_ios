import Foundation

/// Gemensamma funktioner för att formatera tid i sekunder till läsbart format
public extension Int {
	/// Formaterar sekunder till MM:SS format (t.ex. "02:30")
	/// Används för timer-display där man vill ha konsekvent formatering
	var timeString: String {
		let m = self / 60
		let s = self % 60
		return String(format: "%02d:%02d", m, s)
	}
	
	/// Formaterar sekunder till kompakt format (t.ex. "30s" eller "2m 30s")
	/// Används för kompakt visning i listor och editor-vyer
	var formatDuration: String {
		if self < 60 {
			return "\(self)s"
		} else {
			let m = self / 60
			let s = self % 60
			return s > 0 ? "\(m)m \(s)s" : "\(m)m"
		}
	}
}


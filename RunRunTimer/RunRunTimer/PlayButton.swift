import SwiftUI

#if os(iOS)

/// Storlekar för PlayButton
enum ButtonSize {
    case small
    case medium
    case large
    
    var font: Font {
        switch self {
        case .small:
            return .title3
        case .medium:
            return .title
        case .large:
            return .largeTitle
        }
    }
}

/// En återanvändbar play/pause-knapp för att starta och pausa workouts
/// Kan användas i flera vyer för att starta workouts på ett konsekvent sätt
struct PlayButton: View {
    let action: () -> Void
    let size: ButtonSize
    let isRunning: Bool
    
    /// Skapar en play-knapp (endast play, ingen pause-state)
    /// - Parameters:
    ///   - action: Action som körs när knappen trycks
    ///   - size: Storlek på knappen (standard: .medium)
    init(action: @escaping () -> Void, size: ButtonSize = .medium) {
        self.action = action
        self.size = size
        self.isRunning = false
    }
    
    /// Skapar en play/pause-knapp som växlar mellan play och pause
    /// - Parameters:
    ///   - isRunning: Om workouten körs (visar pause) eller är pausad (visar play)
    ///   - action: Action som körs när knappen trycks (t.ex. toggle play/pause)
    ///   - size: Storlek på knappen (standard: .medium)
    init(isRunning: Bool, action: @escaping () -> Void, size: ButtonSize = .medium) {
        self.isRunning = isRunning
        self.action = action
        self.size = size
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                .font(size.font)
                .foregroundColor(.accent)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Preview

#if DEBUG
#Preview {
    VStack(spacing: 40) {
        // Play-only buttons
        PlayButton(action: {
            print("Small play tapped")
        }, size: .small)
        
        PlayButton(action: {
            print("Play tapped")
        })
        
        PlayButton(action: {
            print("Large play tapped")
        }, size: .large)
        
        Divider()
            .padding()
        
        // Play/Pause buttons
        HStack(spacing: 20) {
            PlayButton(isRunning: false, action: {
                print("Large start")
            }, size: .small)
            
            PlayButton(isRunning: true, action: {
                print("Large pause")
            }, size: .small)
        }
        
        HStack(spacing: 20) {
            PlayButton(isRunning: false, action: {
                print("Start workout")
            })
            
            PlayButton(isRunning: true, action: {
                print("Pause workout")
            })
        }
        
        HStack(spacing: 20) {
            PlayButton(isRunning: false, action: {
                print("Large start")
            }, size: .large)
            
            PlayButton(isRunning: true, action: {
                print("Large pause")
            }, size: .large)
        }
    }
    .padding()
}
#endif

#endif


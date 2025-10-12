import SwiftUI

#if os(watchOS)

/// Enkel testvy för att verifiera att Watch-bygget fungerar
struct TestView: View {
    var body: some View {
        VStack {
            Text("Hello Watch!")
                .font(.headline)
            Text("Om du ser detta fungerar bygget!")
                .font(.caption)
        }
    }
}

#Preview {
    TestView()
}

#endif


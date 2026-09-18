import SwiftUI

/// Shows text one character at a time, like a typewriter.
/// Just swap `Text(someString)` for `TypewriterText(text: someString)` anywhere.
struct TypewriterText: View {
    let text: String
    var speed: Double = 0.02   // seconds per character — smaller = faster

    @State private var displayedText = ""
    @State private var typingTask: Task<Void, Never>?

    var body: some View {
        Text(displayedText)
            .onAppear { startTyping() }
            .onChange(of: text) { _, _ in startTyping() }
            .onDisappear { typingTask?.cancel() }
    }

    private func startTyping() {
        typingTask?.cancel()          // stop any typing already in progress
        displayedText = ""            // start from an empty line

        typingTask = Task {
            for character in text {
                if Task.isCancelled { return }
                try? await Task.sleep(nanoseconds: UInt64(speed * 1_000_000_000))
                await MainActor.run {
                    displayedText.append(character)
                }
            }
        }
    }
}

#Preview {
    TypewriterText(text: "Eh, ada teman-temannya Encep. Sini masuk!")
        .font(.title3)
        .padding()
}

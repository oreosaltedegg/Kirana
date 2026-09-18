import SwiftUI

/// Your "cast list" — one color per character, so every line "Ambu" says
/// always shows in the same color, without repeating it in every scene.
///
/// To add a new character: just add one more line below.
enum CharacterStyle {
    static let speakerColors: [String: String] = [
        "Abah": "#C49A6C",
        "Ambu": "#CB9AC7",   // purple
        "Encep": "#E56F4B",  // orange
        "Boaz": "#F15A5C",   // red
        "Hotma": "#F59799",    // pink
        "Waha": "#FDBA40"    // yellow
    ]

    /// The default color used when a speaker isn't in the list above,
    /// or when a scene has no speaker at all (narration).
    static let defaultColor = "#8C66B3"

    static func color(for speaker: String?) -> Color {
        guard let speaker, let hex = speakerColors[speaker] else {
            return Color(hex: defaultColor)
        }
        return Color(hex: hex)
    }
}

extension Color {
    /// Lets us write Color(hex: "#8C66B3") instead of Color(red:green:blue:).
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value & 0xFF0000) >> 16) / 255
        let g = Double((value & 0x00FF00) >> 8) / 255
        let b = Double(value & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

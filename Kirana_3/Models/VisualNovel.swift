import Foundation

// One entry per story in the library list.
// To add a NEW story later: add an image + json file to Resources/Stories,
// then add one entry here in stories_index.json — no code changes needed.
struct StoryIndexEntry: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String          // short teaser shown on the card
    let coverImage: String        // name of image in Assets.xcassets
    let fileName: String          // name of the .json file (without extension) in Resources/Stories
}

// A full visual novel story: a set of scenes connected by "next" or "choices".
struct VisualNovelStory: Codable {
    let id: String
    let title: String
    let startSceneId: String
    let backgroundMusic: String?
    let scenes: [VNScene]
}

struct VNScene: Codable, Identifiable, Hashable {
    let id: String
    let background: String?
    let backgroundBlur: Bool? 
    let characterImage: String?
    let characterPlacement: VNCharacterPlacement?
    let voiceover: String?
    let speaker: String?
    let text: String
    let choices: [VNChoice]?
    let next: String?
    
    var isBackgroundBlurred: Bool {
        backgroundBlur ?? false
    }
}

struct VNCharacterPlacement: Codable, Hashable {
    let width: Double?
    let height: Double?
    let xOffset: Double?
    let yOffset: Double?
}

struct VNChoice: Codable, Hashable {
    let text: String
    let nextSceneId: String
}

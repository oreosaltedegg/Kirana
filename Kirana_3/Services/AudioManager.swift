import AVFoundation
import Combine

/// Handles two separate audio players:
/// - background music, which loops forever at low volume, using AVPlayer
///   (the same engine used for video — much more forgiving of imperfectly
///   encoded audio files than AVAudioPlayer).
/// - voiceover, which plays once per scene using AVAudioPlayer, only if
///   that scene has one.
final class AudioManager: ObservableObject {
    @Published private(set) var isMusicMuted = false
    @Published private(set) var isVoiceoverMuted = false

    private var musicPlayer: AVPlayer?
    private var musicLoopObserver: NSObjectProtocol?
    private var voiceoverPlayer: AVAudioPlayer?

    private let musicVolume: Float = 0.2
    private let voiceoverVolume: Float = 1.1

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    /// Starts looping background music. Safe to call with `nil` (does nothing).
    func startMusic(named name: String?) {
        stopMusic()
        guard let name, let url = findAudioURL(named: name) else { return }

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.volume = isMusicMuted ? 0 : musicVolume
        player.play()

        // AVPlayer doesn't loop on its own, so we listen for "reached the end"
        // and jump back to the start every time it happens.
        musicLoopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }

        musicPlayer = player
    }

    func stopMusic() {
        musicPlayer?.pause()
        if let observer = musicLoopObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        musicLoopObserver = nil
        musicPlayer = nil
    }

    /// Plays a scene's voiceover once. Safe to call with `nil` — it will
    /// just stop whatever voiceover was playing before, with nothing new starting.
    func playVoiceover(named name: String?) {
        voiceoverPlayer?.stop()
        voiceoverPlayer = nil
        guard let name, let url = findAudioURL(named: name) else { return }
        do {
            voiceoverPlayer = try AVAudioPlayer(contentsOf: url)
            voiceoverPlayer?.volume = isVoiceoverMuted ? 0 : voiceoverVolume
            voiceoverPlayer?.play()
        } catch {
            print("AudioManager: couldn't play voiceover '\(name)': \(error)")
        }
    }

    func toggleMusicMute() {
        isMusicMuted.toggle()
        musicPlayer?.volume = isMusicMuted ? 0 : musicVolume
    }

    func toggleVoiceoverMute() {
        isVoiceoverMuted.toggle()
        voiceoverPlayer?.volume = isVoiceoverMuted ? 0 : voiceoverVolume
    }

    func stopAll() {
        stopMusic()
        voiceoverPlayer?.stop()
        voiceoverPlayer = nil
    }

    /// The JSON just has a filename like "music_1" with no extension,
    /// so we try the common audio formats until one exists in the app bundle.
    private func findAudioURL(named name: String) -> URL? {
        for ext in ["mp3", "m4a", "wav", "caf"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        print("AudioManager: could not find \"\(name)\" with any of .mp3/.m4a/.wav/.caf in the app bundle. Check that the file is added to Xcode with your app target checked.")
        return nil
    }
}

import SwiftUI

struct VisualNovelPlayerView: View {
    let storyFileName: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var story: VisualNovelStory?
    @State private var scenesById: [String: VNScene] = [:]
    @State private var currentSceneId: String?
    @State private var loadError: String?
    
    @State private var sceneHistory: [String] = []
    
    @StateObject private var audio = AudioManager()
    
    var body: some View {
        GeometryReader { geo in
            let topInset = geo.safeAreaInsets.top

            VStack(spacing: 0) {
                illustrationView
                    .frame(width: geo.size.width, height: geo.size.height * 0.70)
                    .clipped()

                dialoguePanel
                    .frame(width: geo.size.width, height: geo.size.height * 0.45, alignment: .topLeading)
            }
            .ignoresSafeArea(edges: .top)
            .overlay(alignment: .topLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(16)
                        .background(.black.opacity(0.24))
                        .clipShape(Circle())
                }
                .padding(.top, topInset - 60)
                .padding(.leading, 20)
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 10) {
                    Button {
                        audio.toggleMusicMute()
                    } label: {
                        Image(systemName: audio.isMusicMuted ? "music.note.slash" : "music.note")
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    }
                    Button {
                        audio.toggleVoiceoverMute()
                    } label: {
                        Image(systemName: audio.isVoiceoverMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(14)
                .background(.black.opacity(0.24))
                .clipShape(Capsule())
                .padding(.top, topInset - 60)
                .padding(.trailing, 20)
            }
        }
        .background(Color("mybackground").ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear(perform: loadStory)
        .onChange(of: currentSceneId) { _, _ in
            audio.playVoiceover(named: currentScene?.voiceover)
        }
        .onDisappear {
            audio.stopAll()
        }
    }
    
    private var illustrationView: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                if let scene = currentScene, let bg = scene.background, UIImage(named: bg) != nil {
                    Image(bg)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: scene.isBackgroundBlurred ? 2 : 0)
                } else {
                    Color(red: 0.75, green: 0.88, blue: 0.95)
                }
                
                if let scene = currentScene,
                   let characterImage = scene.characterImage,
                   UIImage(named: characterImage) != nil {
                    let placement = scene.characterPlacement
                    let width = CGFloat(placement?.width ?? geo.size.width * 0.45)
                    let height = placement?.height.map { CGFloat($0) }
                    let xOffset = CGFloat(placement?.xOffset ?? 0)
                    let yOffset = CGFloat(placement?.yOffset ?? 0)
                    
                    Image(characterImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                        .offset(x: xOffset, y: yOffset)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
            .overlay(tapZones)
        }
    }
    
    private var dialoguePanel: some View {
        ZStack(alignment: .topLeading) {
            Color("mybackground")
            
            if let scene = currentScene {
                ZStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let speaker = scene.speaker, !speaker.isEmpty {
                            Text(speaker)
                                .font(.custom("Fredoka", size: 14, relativeTo: .headline))
                                .fontWeight(.medium)
                                .foregroundStyle(CharacterStyle.color(for: speaker))
                        }
                        
                        if !scene.text.isEmpty {
                            TypewriterText(text: scene.text)
//                                .font(.title3)
                                .font(.custom("Fredoka", size: 20, relativeTo: .title3))
                                .fontWeight(.semibold)
                                .foregroundStyle(.grey)
                        }
                        
                        if let choices = scene.choices, !choices.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(choices, id: \.self) { choice in
                                    Button {
                                        advance(to: choice.nextSceneId)
                                    } label: {
                                        Text(choice.text)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                    }
                                    .background(Color(red: 0.93, green: 0.78, blue: 0.28))
                                    .foregroundStyle(.black)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(.top, 12)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(scene.choices == nil ? AnyView(tapZones) : AnyView(EmptyView()))
                }
            } else if let loadError {
                Text(loadError)
                    .foregroundStyle(.red)
                    .padding(20)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard let scene = currentScene else { return }
            if (scene.choices == nil || scene.choices!.isEmpty), let next = scene.next {
                advance(to: next)
            }
        }
    }
    
    private var tapZones: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goBack() }
                    .frame(width: geo.size.width * 0.30)

                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goForward() }
            }
        }
    }
    
    private func goForward() {
        guard let scene = currentScene, let next = scene.next else { return }
        advance(to: next)
    }
    
    private func advance(to id: String) {
        if let current = currentSceneId {
            sceneHistory.append(current)
        }
        withAnimation(.easeInOut(duration: 0.5)) {
            currentSceneId = id
        }
    }
    
    private func goBack() {
        guard let previous = sceneHistory.popLast() else { return }
        withAnimation(.easeInOut(duration: 0.5)){
            currentSceneId = previous
        }
    }
    
    private var currentScene: VNScene? {
        guard let id = currentSceneId else { return nil }
        return scenesById[id]
    }
    
    private func loadStory() {
        guard let url = Bundle.main.url(forResource: storyFileName, withExtension: "json") else {
            loadError = "Could not find \(storyFileName).json in the app bundle."
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(VisualNovelStory.self, from: data)
            story = decoded
            scenesById = Dictionary(uniqueKeysWithValues: decoded.scenes.map { ($0.id, $0) })
            currentSceneId = decoded.startSceneId
            audio.startMusic(named: decoded.backgroundMusic)
        } catch {
            loadError = "Could not read \(storyFileName).json: \(error.localizedDescription)"
        }
    }
}

#Preview {
    VisualNovelPlayerView(storyFileName: "story_ambu")
}

import SwiftUI

struct StoryLibraryView: View {
    @State private var stories: [StoryIndexEntry] = []
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Ceria")
                        .font(.custom("Fredoka", size: 34, relativeTo: .largeTitle))
                        .bold()
                        .foregroundStyle(Color.grey)
                        .padding(.horizontal)

                    Text("Cerita Anak Berbudaya")
                        .font(.custom("Fredoka", size: 20, relativeTo: .subheadline))
                        .foregroundStyle(Color("mysecondary"))
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        if let loadError {
                            Text(loadError)
                                .foregroundStyle(.red)
                        }

                        ForEach(stories) { story in
                            NavigationLink(value: story) {
                                StoryCoverCard(story: story)
                            }
                            .buttonStyle(.plain)
                        }

                        // A simple placeholder card for a story that isn't written yet.
                        // Not tappable — just here to show "more is coming".
                        ComingSoonStoryCard()
                    }
                    .padding()
                }
            }
            .background(Color("mybackground").ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: StoryIndexEntry.self) { entry in
                VisualNovelPlayerView(storyFileName: entry.fileName)
            }
            .onAppear(perform: loadIndex)
        }
    }

    private func loadIndex() {
        guard let url = Bundle.main.url(forResource: "stories_index", withExtension: "json") else {
            loadError = "Could not find stories_index.json in the app bundle."
            return
        }
        do {
            let data = try Data(contentsOf: url)
            stories = try JSONDecoder().decode([StoryIndexEntry].self, from: data)
        } catch {
            loadError = "Could not read stories_index.json: \(error.localizedDescription)"
        }
    }
}

/// A big illustrated card: colored background, optional illustration on top,
/// title + short teaser text at the bottom.
struct StoryCoverCard: View {
    let story: StoryIndexEntry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // The illustration itself, filling the whole card.
            if UIImage(named: story.coverImage) != nil {
                Image(story.coverImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(red: 0.93, green: 0.78, blue: 0.28)
            }

            // A dark gradient behind the text — this is what keeps the
            // title readable no matter how bright or busy the artwork is.
            LinearGradient(
                colors: [.black.opacity(0.05), .black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
//                Text("Cerita Baru")
//                    .font(.caption.bold())
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 5)
//                    .background(.black.opacity(0.55))
//                    .foregroundStyle(.white)
//                    .clipShape(Capsule())

                Text(story.title)
                    .font(.custom("Fredoka", size: 30, relativeTo: .title))
                    .bold()
                    .foregroundStyle(.white)
                    // Belt-and-suspenders on top of the gradient: a soft
                    // shadow directly on the text for any tricky spots.
                    .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)
                    .lineLimit(2)
                
                Text(story.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .padding(.bottom, 4)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
        
    }
}

/// A grayed-out card that just says "more stories coming soon" — not tappable.
struct ComingSoonStoryCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.grey).opacity(0.05))
                .frame(height: 140)
            
            VStack(spacing: 8) {
                Image(systemName: "questionmark.circle.dashed")
                    .font(.system(size: 32))
                    .foregroundStyle(.mysecondary)
                Text("Segera Hadir")
                    .font(.custom("Fredoka", size: 20, relativeTo: .body))
                    .foregroundStyle(.mysecondary)
            }
        }
    }
}

#Preview {
    StoryLibraryView()
}

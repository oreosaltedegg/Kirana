//
//  ContentView.swift
//  Kirana_3
//
//  Created by Anabel Oklana on 14/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            StoryLibraryView()
                .tabItem { Label("Ceria", systemImage: "book.fill") }

            ComingSoonView(title: "Raya", subtitle: "Ragam Karya")
                .tabItem { Label("Raya", systemImage: "pencil.and.scribble") }

            ComingSoonView(title: "Kiasan", subtitle: "Kuis Kebahasaan Untuk Anak")
                .tabItem { Label("Kiasan", systemImage: "star.fill") }
        }
        .tint(.yellow)
        .background(Color("mybackground").ignoresSafeArea())
        .toolbarBackground(.hidden, for: .bottomBar)
    }
}

#Preview {
    ContentView()
}

//
//  EpisodeDetailView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 25.05.2024.
//

import SwiftUI
import SwiftData



struct EpisodeDetailView: View {
    
    @Query var episodes: [EpisodesEntity]
    @Environment(\.modelContext) var modelContext
    @State private var gridItem: [GridItem] = [GridItem(), GridItem()]
    @State private var alert: AppError? = nil
    var characters: [Character]
    let episode: Episode
    
    @ViewBuilder func makeHStack(for text: String, with title: String) -> some View {
        HStack(alignment: .center) {
            Text(title + ":")
                .foregroundStyle(Color.gray)
            Text(text)
                .font(.title3)
            Spacer()
        }
        .padding(.leading, 10)
        .padding(.bottom, 5)
        .padding(.top, 5)
    }
    
    var body: some View {
        ScrollView {
            HStack {
                Text(episode.name)
                    .padding()
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Button {
                    if episodes.contains(where: { $0.id == episode.id }) {
                        if let ep = episodes.first(where: { $0.id ==  episode.id }) {
                            modelContext.delete(ep)
                        }
                    } else {
                        let ep = EpisodesEntity(id: episode.id, name: episode.name, airDate: episode.airDate, episode: episode.episode, url: episode.url, created: episode.created)
                        modelContext.insert(ep)
                    }
                } label: {
                    Image(systemName: episodes.contains(where: { $0.id == episode.id }) ? "bookmark.fill": "bookmark")
                        .padding()
                        .font(.title)
                        .foregroundStyle(episodes.contains(where: { $0.id == episode.id }) ? Color.red : Color.primary)
                }

            }
            VStack {
                makeHStack(for: episode.episode, with: "Episode")
                makeHStack(for: episode.airDate, with: "Air date")
                makeHStack(for: episode.created.dateFormater, with: "Created")
            }
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
            }
            .padding(5)
            Text("Characters")
                .padding()
                .font(.title3)
                .foregroundStyle(Color.gray)
            if !characters.isEmpty {
                LazyVGrid(columns: gridItem) {
                    ForEach(characters, id: \.self) { character in
                        NavigationLink(value: character) {
                            CharackterPresentationView(character: character)
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    EpisodeDetailView(characters: [DeveloperPreview.instanse.charackter], episode: DeveloperPreview.instanse.episode)
}

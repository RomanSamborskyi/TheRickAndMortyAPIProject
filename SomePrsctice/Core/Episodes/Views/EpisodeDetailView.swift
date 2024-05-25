//
//  EpisodeDetailView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 25.05.2024.
//

import SwiftUI

struct EpisodeDetailView: View {
    
    @ObservedObject var vm: EpisodesViewModel
    @State private var gridItem: [GridItem] = [GridItem(), GridItem()]
    let episode: Episode
    
    var body: some View {
        ScrollView {
            Text(episode.name)
            Text(episode.episode)
            Text(episode.airDate)
            Text(episode.created)
            
            Text("Characters")
                .padding()
                .font(.title3)
            LazyVGrid(columns: gridItem) {
                ForEach(vm.characters, id: \.self) { character in
                    NavigationLink(value: character) {
                        CharackterPresentationView(character: character)
                            .foregroundStyle(Color.primary)
                    }
                }
            }
        }
        .navigationDestination(for: Character.self) { character in
            CharacterDetailView(character: character)
        }
        .task {
            do {
                for url in episode.characters {
                    try await vm.getCharacterForEpisode(with: url)
                }
            } catch {
                
            }
        }
    }
}

#Preview {
    EpisodeDetailView(vm: EpisodesViewModel(apiManager: APIManager()), episode: DeveloperPreview.instanse.episode)
}

//
//  SwiftUIView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 08.06.2024.
//

import SwiftUI
import SwiftData



struct SavedItemsMainView: View {
    
    @State private var savedItems: SavedItems = .character
    
    var body: some View {
        VStack {
            Picker("", selection: $savedItems) {
                ForEach(SavedItems.allCases, id: \.self) { tab in
                    Text(tab.description)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch savedItems {
            case .character:
                SavedCharacters()
            case .episode:
                SavedEpisodes()
            case .location:
                SavedLocations()
            }
        }
    }
}

#Preview {
    SavedItemsMainView()
}


struct SavedCharacters: View {
    @Query var characters: [CharacterEntity]
    @Environment(\.modelContext) var modelContex
    let gridItems: [GridItem] = [GridItem(), GridItem()]
    
    var body: some View {
        ScrollView {
            if !characters.isEmpty {
                LazyVGrid(columns: gridItems) {
                    ForEach(characters) { character in
                        let char = Character(id: character.id, name: character.name, status: character.status, species: character.species, type: character.type, gender: character.gender, origin: nil, location: nil, image: "", episode: [], url: "", created: character.created)
                        CharackterPresentationView(character: char)
                            .contextMenu(ContextMenu(menuItems: {
                                Button {
                                    modelContex.delete(character)
                                } label: {
                                    Text("Delete")
                                }
                            }))
                    }
                }
            } else {
                Image(systemName: "person.fill")
                    .padding()
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                Text("NO SAVED EPISODES")
                    .padding()
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct SavedEpisodes: View {
    
    @Query var episodes: [EpisodesEntity]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        ScrollView {
            VStack {
                if !episodes.isEmpty {
                    ForEach(episodes) { episode in
                        let ep = Episode(id: episode.id, name: episode.name, airDate: episode.airDate, episode: episode.episode, characters: [], url: episode.url, created: episode.created)
                        PresentationView(item: ep)
                            .frame(maxWidth: .infinity)
                            .contextMenu(ContextMenu(menuItems: {
                                Button {
                                    modelContext.delete(episode)
                                } label: {
                                    Text("Delete")
                                }
                            }))
                    }
                } else {
                    Image(systemName: "tv")
                        .padding()
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                    Text("NO SAVED EPISODES")
                        .padding()
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}


struct SavedLocations: View {
    
    @Query var locations: [LocationEntity]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        ScrollView {
            VStack {
                if !locations.isEmpty {
                    ForEach(locations) { location in
                        let loc = SingleLocation(id: location.id, name: location.name, type: location.type, dimension: location.dimension, residents: [], url: location.url, created: location.created)
                        PresentationView(item: loc)
                            .frame(maxWidth: .infinity)
                            .contextMenu(ContextMenu(menuItems: {
                                Button {
                                    modelContext.delete(location)
                                } label: {
                                    Text("Delete")
                                }
                            }))
                    }
                } else {
                    Image(systemName: "globe")
                        .padding()
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                    Text("NO SAVED LOCATIONS")
                        .padding()
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

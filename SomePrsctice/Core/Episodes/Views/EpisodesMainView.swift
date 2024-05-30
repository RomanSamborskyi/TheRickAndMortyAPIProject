//
//  EpisodesMainView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI

struct EpisodesMainView: View {
    
    @StateObject var vm: EpisodesViewModel
    @State private var searchText: String = ""
    @State private var alert: AppError? = nil
    
    init() {
        _vm = StateObject(wrappedValue: EpisodesViewModel(apiManager: APIManager()))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(vm.episodes, id: \.self) { episode in
                        NavigationLink(value: episode) {
                            EpisodePresentationGenericView(episode: episode)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    SpiningView1(alert: $alert, vm: vm)
                }
                .navigationDestination(for: Episode.self) { episode in
                    EpisodeDetailView(characters: vm.characters[episode] ?? [], episode: episode)
                        .task {
                            do {
                                try await vm.getExtraInfo(for: episode)
                            } catch {
                                self.alert = AppError.badURL
                            }
                        }
                        .onDisappear {
                            vm.characters.removeAll()
                        }
                }
                .navigationDestination(for: Character.self) { character in
                    CharacterDetailView(episodes: vm.episodesForCharacter[character] ?? [], character: character)
                        .task {
                            do {
                                try await vm.getEpisodes(for: character)
                            } catch {
                                self.alert = AppError.badURL
                            }
                        }
                        .onDisappear {
                            vm.episodesForCharacter.removeAll()
                        }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Episodes")
            .alert(alert?.localizedDescription ?? "", isPresented: Binding(value: $alert), actions: { })
            .task {
                if vm.episodes.isEmpty {
                    do {
                        try await vm.getEpisodes(with: APIEpisodesEndpoints.baseURl.endpoints)
                    } catch {
                        self.alert = AppError.badURL
                    }
                }
            }
            .onChange(of: searchText) { _, newValue in
                Task {
                    if newValue.count > 2 {
                        do {
                            vm.episodes.removeAll()
                            try await vm.getEpisodes(with: vm.search(episode: newValue) ?? "")
                        } catch {
                            self.alert = AppError.badURL
                        }
                    } else if searchText.count == 0 {
                        do {
                            vm.episodes.removeAll()
                            try await vm.getEpisodes(with: APIEpisodesEndpoints.baseURl.endpoints)
                        } catch {
                            self.alert = AppError.badURL
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    EpisodesMainView()
}

struct SpiningView1: View {
    @Binding var alert: AppError?
    @ObservedObject var vm: EpisodesViewModel
    
    var body: some View {
        VStack {
            ProgressView()
        }
        .task {
            if !vm.episodes.isEmpty && vm.nextURL != nil {
                do {
                    try await vm.getEpisodes(with: vm.nextURL ?? "")
                } catch {
                    self.alert = AppError.badURL
                }
            }
        }
    }
}

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
                            EpisodeView(episode: episode)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    SpiningView1(alert: $alert, vm: vm)
                }
            }
            .searchable(text: $searchText)
            .navigationDestination(for: Episode.self) { episode in
                EpisodeDetailView(vm: vm, episode: episode)
            }
            .navigationTitle("Episodes")
            .alert(alert?.localizedDescription ?? "", isPresented: Binding(value: $alert), actions: { })
            .task {
                if vm.episodes.isEmpty {
                    do {
                        try await vm.getEpisodes(with: "https://rickandmortyapi.com/api/episode")
                    } catch {
                        print(error)
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
                    } else if searchText.count < 2 || searchText.count == 0 {
                        do {
                            vm.episodes.removeAll()
                            try await vm.getEpisodes(with: "https://rickandmortyapi.com/api/episode")
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

struct EpisodeView: View {
    
    let episode: Episode
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(episode.name)
                .font(.title3)
            Text(episode.episode)
                .font(.callout)
                .foregroundStyle(Color.gray)
            Divider()
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .padding(.leading, 20)
    }
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

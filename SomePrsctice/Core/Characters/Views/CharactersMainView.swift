//
//  CharactersMainView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI

struct CharactersMainView: View {
    
    @AppStorage("filterByStatus") private var filterByStatus: FilterCharactersStatus = .non
    @AppStorage("filterByGender") private var filterByGender: FilterCharactersGender = .non
    @StateObject var vm: CharactersViewModel
    @State private var alert: AppError? = nil
    @State private var showFilterSheet: Bool = false
    @StateObject private var debouncedResult: DebouncedResult = DebouncedResult()
    let gridItem: [GridItem] = [GridItem(), GridItem()]
    init() {
        _vm = StateObject(wrappedValue: CharactersViewModel(apiManger: APIManager()))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridItem) {
                    ForEach(vm.characters) { character in
                        NavigationLink(value: character) {
                            CharackterPresentationView(character: character)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    SpiningView(alert: $alert, vm: vm)
                }
                .navigationDestination(for: Character.self) { character in
                    CharacterDetailView(episodes: vm.episodes[character] ?? [], character: character, location: vm.locationForCharacter[character] ?? DeveloperPreview.instanse.locaton)
                        .task {
                            do {
                                try await vm.getEpisodes(for: character)
                            } catch {
                                self.alert = AppError.badURL
                            }
                        }
                        .onDisappear {
                            vm.episodes.removeAll()
                        }
                }
                .navigationDestination(for: Episode.self) { episode in
                    EpisodeDetailView(characters: vm.charactersForEpisode[episode] ?? [], episode: episode)
                        .task {
                            do {
                                try await vm.getCharacter(for: episode)
                            } catch {
                                self.alert = AppError.badURL
                            }
                        }
                        .onDisappear {
                            vm.charactersForEpisode.removeAll()
                        }
                }
                .navigationDestination(for: SingleLocation.self) { location in
                    LocationDetailView(characters: vm.charactersForLocation[location] ?? [], location: location)
                        .task {
                            do {
                                try await vm.fetchCharacters(for: location)
                            } catch {
                                print(error)
                                self.alert = AppError.noInternet
                            }
                        }
                        .onDisappear {
                            vm.charactersForLocation.removeAll()
                        }
                }
            }
            .navigationTitle("Characters")
            .alert(alert?.localizedDescription ?? "", isPresented: Binding(value: $alert), actions: { })
            .task {
                if vm.characters.isEmpty {
                    do {
                        try await vm.getCharacters(with: APICharactersEndpoints.baseURL(endpoint: .allCahracters(page: 1)).endpoints)
                    } catch {
                        self.alert = AppError.badURL
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.showFilterSheet.toggle()
                    } label: {
                        Image(systemName: filterByGender == .non && filterByStatus == .non ? "slider.horizontal.2.square" : "slider.horizontal.2.square.badge.arrow.down")
                            .symbolEffect(.bounce, value: showFilterSheet)
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterPageView(vm: vm, filterByStatus: $filterByStatus, filterByGender: $filterByGender)
            }
            .searchable(text: $debouncedResult.searchText, prompt: "Search characters...")
            .onChange(of: debouncedResult.searchText) { _, newValue in
                Task {
                    if newValue.count > 2 {
                        vm.characters.removeAll()
                        do {
                            try await vm.getCharacters(with: vm.search(with: newValue) ?? "")
                        } catch {
                            self.alert = AppError.noSearchResult
                        }
                    } else if newValue.count < 2 && newValue.count == 0 {
                        vm.characters.removeAll()
                        debouncedResult.debounceCancellable?.cancel()
                        do {
                            try await vm.getCharacters(with: APICharactersEndpoints.baseURL(endpoint: .allCahracters(page: 1)).endpoints)
                        } catch AppError.badURL {
                            self.alert = AppError.badURL
                        } catch AppError.noInternet {
                            self.alert = AppError.noInternet
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CharactersMainView()
}


struct SpiningView: View {
    @Binding var alert: AppError?
    @ObservedObject var vm: CharactersViewModel
    
    var body: some View {
        VStack {
            ProgressView()
        }
        .task {
            if !vm.characters.isEmpty && vm.nextURL != nil {
                do {
                    try await vm.getCharacters(with: vm.nextURL ?? "")
                } catch {
                    self.alert = AppError.badURL
                }
            }
        }
    }
}

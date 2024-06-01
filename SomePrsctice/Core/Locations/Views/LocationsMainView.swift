//
//  LocationsMainView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI

struct LocationsMainView: View {
    
    @StateObject var vm: LocationsViewModel
    @StateObject private var debouncedResult: DebouncedResult = DebouncedResult()
    @State private var alert: AppError? = nil
    
    init() {
        _vm = StateObject(wrappedValue: LocationsViewModel(apiManager: APIManager()))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(vm.locations, id: \.self) { location in
                        NavigationLink(value: location) {
                            PresentationView(item: location)
                        }
                        .foregroundStyle(Color.primary)
                    }
                    SpiningView3(alert: $alert, vm: vm)
                }
                .navigationDestination(for: SingleLocation.self) { location in
                    LocationDetailView(characters: vm.residentsForLocation[location] ?? [], location: location)
                        .task {
                            do {
                                try await vm.getCharacters(for: location)
                            } catch {
                                self.alert = AppError.badURL
                            }
                        }
                        .onDisappear {
                            vm.residentsForLocation.removeAll()
                        }
                }
                .navigationDestination(for: Character.self) { character in
                    CharacterDetailView(episodes: vm.episodes[character] ?? [], character: character)
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
            }
            .searchable(text: $debouncedResult.searchText)
            .navigationTitle("Locations")
            .alert(alert?.localizedDescription ?? "", isPresented: Binding(value: $alert), actions: { })
            .task {
                if vm.locations.isEmpty {
                    do {
                        try await vm.getLocations(with: APILocationEndpoints.baseURl.endpoints)
                    } catch {
                        self.alert = AppError.noInternet
                    }
                }
            }
            .onChange(of: debouncedResult.searchText) { _, newValue in
                Task {
                    if newValue.count > 2 {
                        vm.locations.removeAll()
                        do {
                            try await vm.getLocations(with: vm.search(with: newValue) ?? "")
                        } catch {
                            self.alert = AppError.noSearchResult
                        }
                    } else if newValue.count == 0 {
                        do {
                            vm.locations.removeAll()
                            debouncedResult.debounceCancellable?.cancel()
                            try await vm.getLocations(with: APILocationEndpoints.baseURl.endpoints)
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
    LocationsMainView()
}

struct SpiningView3: View {
    @Binding var alert: AppError?
    @ObservedObject var vm: LocationsViewModel
    
    var body: some View {
        VStack {
            ProgressView()
        }
        .task {
            if !vm.locations.isEmpty && vm.nextURL != nil {
                do {
                    try await vm.getLocations(with: vm.nextURL ?? "")
                } catch {
                    self.alert = AppError.badURL
                }
            }
        }
    }
}

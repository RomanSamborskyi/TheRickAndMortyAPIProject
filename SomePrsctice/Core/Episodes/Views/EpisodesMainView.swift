//
//  EpisodesMainView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI

struct EpisodesMainView: View {
    
    @StateObject var vm: EpisodesViewModel
    @StateObject private var debouncedResult: DebouncedResult = DebouncedResult()
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
                            PresentationView(item: episode)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    SpiningView1(alert: $alert, vm: vm)
                }
                .navigationDestination(for: Episode.self) { episode in
                    EpisodeDetailView(characters: vm.characters[episode] ?? [], episode: episode)
                        .task {
                            await episodesTask(episode: episode)
                        }
                        .onDisappear {
                            vm.characters.removeAll()
                        }
                }
                .navigationDestination(for: Character.self) { character in
                    CharacterDetailView(episodes: vm.episodesForCharacter[character] ?? [], character: character, location: vm.locationForCharacter[character] ?? DeveloperPreview.instanse.locaton)
                        .task {
                            await characterTask(character: character)
                        }
                        .onDisappear {
                            vm.episodesForCharacter.removeAll()
                        }
                }
                .navigationDestination(for: SingleLocation.self) { location in
                    LocationDetailView(characters: vm.charactersForLocation[location] ?? [], location: location)
                        .task {
                            await locationTask(location: location)
                        }
                        .onDisappear {
                            vm.charactersForLocation.removeAll()
                        }
                }
            }
            .searchable(text: $debouncedResult.searchText, prompt: "Search episodes...")
            .navigationTitle("Episodes")
            .alert(alert?.localizedDescription ?? "", isPresented: Binding(value: $alert), actions: { })
            .task {
                await episodesMainTask()
            }
            .onChange(of: debouncedResult.searchText) { _, newValue in
                Task {
                    await searchTask(newValue)
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
                } catch let error as AppError {
                    switch error {
                    case .noInternet:
                        self.alert = AppError.noInternet
                    case .badURL:
                        self.alert = AppError.badURL
                    case .badResponse(let status):
                        self.alert = AppError.badResponse(status: status)
                    case .errorOfDecoding(let error):
                        self.alert = AppError.errorOfDecoding(error)
                    default:
                        print(error)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}


private extension EpisodesMainView {
    ///Get all episodes at first launch or when location array is empty
    func episodesMainTask() async {
        if vm.episodes.isEmpty {
            do {
                try await vm.getEpisodes(with: APIEpisodesEndpoints.baseURl.endpoints)
            } catch let error as AppError {
                switch error {
                case .noInternet:
                    self.alert = AppError.noInternet
                case .badURL:
                    self.alert = AppError.badURL
                case .badResponse(let status):
                    self.alert = AppError.badResponse(status: status)
                case .errorOfDecoding(let error):
                    self.alert = AppError.errorOfDecoding(error)
                default:
                    print(error)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    ///SearchLogic, contains do-catch block for search task
    func searchTask(_ newValue: String) async {
        if newValue.count > 2 {
            do {
                vm.episodes.removeAll()
                try await vm.getEpisodes(with: vm.search(episode: newValue) ?? "")
            } catch {
                self.alert = AppError.noSearchResult
            }
        } else if newValue.count == 0 {
            do {
                vm.episodes.removeAll()
                debouncedResult.debounceCancellable?.cancel()
                try await vm.getEpisodes(with: APIEpisodesEndpoints.baseURl.endpoints)
            } catch let error as AppError {
                switch error {
                case .noInternet:
                    self.alert = AppError.noInternet
                case .badURL:
                    self.alert = AppError.badURL
                case .badResponse(let status):
                    self.alert = AppError.badResponse(status: status)
                case .errorOfDecoding(let error):
                    self.alert = AppError.errorOfDecoding(error)
                case .noSearchResult:
                    self.alert = AppError.noSearchResult
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    ///Episodes tasks, contains do-catch block for episodes task
    func episodesTask(episode: Episode) async {
        do {
            try await vm.getExtraInfo(for: episode)
        } catch let error as AppError {
            switch error {
            case .noInternet:
                self.alert = AppError.noInternet
            case .badURL:
                self.alert = AppError.badURL
            case .badResponse(let status):
                self.alert = AppError.badResponse(status: status)
            case .errorOfDecoding(let error):
                self.alert = AppError.errorOfDecoding(error)
            default:
                print(error)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    ///Character task, contains do-catch block for character task
    func characterTask(character: Character) async {
        do {
            try await vm.getEpisodes(for: character)
        } catch let error as AppError {
            switch error {
            case .noInternet:
                self.alert = AppError.noInternet
            case .badURL:
                self.alert = AppError.badURL
            case .badResponse(let status):
                self.alert = AppError.badResponse(status: status)
            case .errorOfDecoding(let error):
                self.alert = AppError.errorOfDecoding(error)
            default:
                print(error)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    ///Location task, contains do-catch block for location task
    func locationTask(location: SingleLocation) async {
        do {
            try await vm.fetchCharacters(for: location)
        } catch let error as AppError {
            switch error {
            case .noInternet:
                self.alert = AppError.noInternet
            case .badURL:
                self.alert = AppError.badURL
            case .badResponse(let status):
                self.alert = AppError.badResponse(status: status)
            case .errorOfDecoding(let error):
                self.alert = AppError.errorOfDecoding(error)
            default:
                print(error)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

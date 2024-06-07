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
                            await locationTask(location: location)
                        }
                        .onDisappear {
                            vm.residentsForLocation.removeAll()
                        }
                }
                .navigationDestination(for: Character.self) { character in
                    CharacterDetailView(episodes: vm.episodes[character] ?? [], character: character, location: vm.locationForCharacter[character] ?? DeveloperPreview.instanse.locaton)
                        .task {
                            await characterTask(character: character)
                        }
                        .onDisappear {
                            vm.episodes.removeAll()
                        }
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
            }
            .searchable(text: $debouncedResult.searchText, prompt: "Search locations...")
            .navigationTitle("Locations")
            .alert(alert?.localizedDescription ?? "", isPresented: Binding(value: $alert), actions: { })
            .task {
                await locationsMainTask()
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


private extension LocationsMainView {
    ///Get all locations at first launch or when location array is empty
    func locationsMainTask() async {
        if vm.locations.isEmpty {
            do {
                try await vm.getLocations(with: APILocationEndpoints.baseURl.endpoints)
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
            try await vm.getCharacters(for: location)
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

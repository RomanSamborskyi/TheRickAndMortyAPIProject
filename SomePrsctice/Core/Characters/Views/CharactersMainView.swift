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
                            await characterTask(character: character)
                        }
                        .onDisappear {
                            vm.episodes.removeAll()
                        }
                }
                .navigationDestination(for: Episode.self) { episode in
                    EpisodeDetailView(characters: vm.charactersForEpisode[episode] ?? [], episode: episode)
                        .task {
                            await episodesTask(episode: episode)
                        }
                        .onDisappear {
                            vm.charactersForEpisode.removeAll()
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
            .navigationTitle("Characters")
            .alert(alert?.localizedDescription ?? "", isPresented: Binding(value: $alert), actions: { })
            .task {
                await charactersMainTask()
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
                    await searchTask(newValue)
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
    }
}


private extension CharactersMainView {
    ///Get all characters at first launch or when location array is empty
    func charactersMainTask() async {
        if vm.characters.isEmpty {
            do {
                try await vm.getCharacters(with: APICharactersEndpoints.baseURL(endpoint: .allCahracters(page: 1)).endpoints)
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
            try await vm.getCharacter(for: episode)
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


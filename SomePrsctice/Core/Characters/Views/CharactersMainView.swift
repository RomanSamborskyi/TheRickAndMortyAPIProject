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
    @State private var searchText: String = ""
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
                    CharacterDetailView(character: character)
                }
            }
            .navigationTitle("Characters")
            .alert(alert?.localizedDescription ?? "", isPresented: Binding(value: $alert), actions: { })
            .task {
                if vm.characters.isEmpty {
                    do {
                        try await vm.getCharacters(with: APICharactersEndpoints.allCahracters(page: 1).endpoints)
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
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                Task {
                    if newValue.count > 2 {
                        vm.characters.removeAll()
                        try await vm.getCharacters(with: vm.search(with: newValue) ?? "")
                    } else if searchText.count < 2 && searchText.count == 0 {
                        vm.characters.removeAll()
                        do {
                            try await vm.getCharacters(with: APICharactersEndpoints.allCahracters(page: 1).endpoints)
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

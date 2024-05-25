//
//  FilterPageView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 24.05.2024.
//

import SwiftUI

struct FilterPageView: View {
    
    @StateObject var vm: CharactersViewModel
    @Binding var filterByStatus: FilterCharactersStatus
    @Binding var filterByGender: FilterCharactersGender
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            
            Text("Filter")
                .padding()
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Text("Character status")
            Picker("Character status", selection: $filterByStatus) {
                ForEach(FilterCharactersStatus.allCases, id: \.self) { filter in
                    Text(filter.rawValue)
                }
            }
            .padding()
            .pickerStyle(.segmented)
            
            Text("Character gender")
            Picker("Character gender", selection: $filterByGender) {
                ForEach(FilterCharactersGender.allCases, id: \.self) { filter in
                    Text(filter.rawValue)
                }
            }
            .padding()
            .pickerStyle(.segmented)
            
            Button {
                Task {
                    do {
                        vm.characters.removeAll()
                        try await vm.getCharacters(with: vm.filterUrl(status: filterByStatus, gender: filterByGender) ?? "")
                        self.dismiss.callAsFunction()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Show results")
            }
            .padding()
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .foregroundStyle(Color.primary)
            
            if filterByGender != .non || filterByStatus != .non {
                Button {
                    self.filterByGender = .non
                    self.filterByStatus = .non
                    vm.characters.removeAll()
                } label: {
                    Text("Clear filter")
                }
                .padding()
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .foregroundStyle(Color.primary)
            }
            Spacer()
        }
    }
}

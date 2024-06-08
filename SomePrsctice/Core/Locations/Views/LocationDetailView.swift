//
//  LocationDetailView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 30.05.2024.
//

import SwiftUI
import SwiftData

struct LocationDetailView: View {
    
    @Query var locations: [LocationEntity]
    @Environment(\.modelContext) var modelContext
    @State private var alert: AppError? = nil
    @State private var gridItem: [GridItem] = [GridItem(), GridItem()]
    var characters: [Character]
    let location: SingleLocation
    
    @ViewBuilder func makeHStack(for text: String, with title: String) -> some View {
        HStack(alignment: .center) {
            Text(title + ":")
                .foregroundStyle(Color.gray)
            Text(text)
                .font(.title3)
            Spacer()
        }
        .padding(.leading, 10)
        .padding(.bottom, 5)
        .padding(.top, 5)
    }
    
    var body: some View {
        ScrollView {
            HStack {
                Text(location.name)
                    .padding()
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Button {
                    if locations.contains(where: { $0.id == location.id }) {
                        if let loc = locations.first(where: { $0.id == location.id }) {
                            modelContext.delete(loc)
                        }
                    } else {
                        let loc = LocationEntity(id: location.id, name: location.name, type: location.type, dimension: location.dimension, url: location.url, created: location.created)
                        modelContext.insert(loc)
                    }
                } label: {
                    Image(systemName: locations.contains(where: { $0.id == location.id }) ? "bookmark.fill": "bookmark")
                        .padding()
                        .font(.title)
                        .foregroundStyle(locations.contains(where: { $0.id == location.id }) ? Color.red : Color.primary)
                }
            }
            VStack {
                makeHStack(for: location.dimension, with: "Dimension")
                makeHStack(for: location.type, with: "Type")
                makeHStack(for: location.created.dateFormater, with: "Created")
            }
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
            }
            .padding(5)
            Text("Residents:")
                .padding()
                .font(.title3)
                .foregroundStyle(Color.gray)
            if !characters.isEmpty {
                LazyVGrid(columns: gridItem) {
                    ForEach(characters, id: \.self) { character in
                        NavigationLink(value: character) {
                            CharackterPresentationView(character: character)
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
            } else if location.residents.isEmpty {
                Text("NO RESIDENTS")
                    .padding()
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Image(systemName: "person.2.slash.fill")
                    .padding()
                    .font(.largeTitle)
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    LocationDetailView(characters: [DeveloperPreview.instanse.charackter], location: DeveloperPreview.instanse.locaton)
}

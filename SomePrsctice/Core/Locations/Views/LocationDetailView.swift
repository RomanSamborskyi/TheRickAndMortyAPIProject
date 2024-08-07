//
//  LocationDetailView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 30.05.2024.
//

import SwiftUI
import SwiftData

struct LocationDetailView: View {
    
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
            Text(location.name)
                .padding()
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
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

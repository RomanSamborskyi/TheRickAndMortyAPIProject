//
//  LocationDetailView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 30.05.2024.
//

import SwiftUI

struct LocationDetailView: View {
    
    @State private var alert: AppError? = nil
    var characters: [Character]
    @State private var gridItem: [GridItem] = [GridItem(), GridItem()]
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
            Text("Characters")
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
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    LocationDetailView(characters: [DeveloperPreview.instanse.charackter], location: DeveloperPreview.instanse.locaton)
}

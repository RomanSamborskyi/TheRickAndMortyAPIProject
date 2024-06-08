//
//  CharacterDetailView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 22.05.2024.
//

import SwiftUI
import SwiftData

struct CharacterDetailView: View {

    let episodes: [Episode]
    let character: Character
    let location: SingleLocation
    @State private var alert: AppError? = nil
    
    @Environment(\.modelContext) var modelContext
    @Query var characters: [CharacterEntity]
    
    var characterStatus: String {
        if character.status == "Alive" {
            return character.status + " " + "🟢"
        } else {
            return character.status + " " + "🔴"
        }
    }
    
    var charackterType: String? {
        if character.type == "" {
            return nil
        } else {
            return character.type
        }
    }
    
    @ViewBuilder func form(for text: String, with title: String) -> some View {
        VStack {
            Text(title)
                .foregroundStyle(Color.gray)
            Text(text)
                .frame(maxWidth: .infinity)
                .frame(height: 25)
                .font(.title3)
                .fontWeight(.bold)
                .padding(15)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 3)
                }
        }
        .padding(5)
    }
    
    var body: some View {
        ScrollView {
            CharacterImageView(imageURL: character.image, imageID: String(character.id))
            
            HStack {
                Text(character.name)
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                Button {
                    if characters.contains(where: { $0.id == character.id }) {
                        let char = characters.first(where: { $0.id == character.id })
                        modelContext.delete(char!)
                    } else {
                        modelContext.insert(CharacterEntity(id: character.id, name: character.name, status: character.status, species: character.species, type: character.type, gender: character.gender, location: character.location?.name ?? "", image: "", created: character.created))
                    }
                } label: {
                    Image(systemName: characters.contains(where: { $0.id == character.id }) ? "bookmark.fill": "bookmark")
                        .padding()
                        .font(.title)
                        .foregroundStyle(characters.contains(where: { $0.id == character.id }) ? Color.red : Color.primary)
                }
            }
            HStack {
                form(for: character.gender, with: "gender")
                form(for: characterStatus, with: "status")
            }
            HStack {
                form(for: character.species, with: "species")
                form(for: character.type, with: "type")
                    .minimumScaleFactor(0.6)
            }
            NavigationLink(value: location) {
                form(for: character.location?.name ?? "", with: "Location")
            }
            .foregroundStyle(Color.primary)
            form(for: character.created.dateFormater, with: "created")
            
            Text("Episodes:")
                .foregroundStyle(Color.gray)
                .padding(.top, 5)
            if !episodes.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(episodes) { episode in
                            NavigationLink(value: episode) {
                                PresentationView(item: episode)
                            }
                            .foregroundStyle(Color.primary)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .padding(.bottom, 50)
    }
}

#Preview {
    CharacterDetailView(episodes: [DeveloperPreview.instanse.episode], character: DeveloperPreview.instanse.charackter, location: DeveloperPreview.instanse.locaton)
}


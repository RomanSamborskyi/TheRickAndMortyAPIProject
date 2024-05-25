//
//  CharacterDetailView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 22.05.2024.
//

import SwiftUI

struct CharacterDetailView: View {

    @ObservedObject var characterVM: CharactersViewModel
    @State private var alert: AppError? = nil
    let character: Character
    
    
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
            Text(character.name)
                .padding()
                .font(.title)
                .fontWeight(.bold)
            HStack {
                form(for: character.gender, with: "gender")
                form(for: characterStatus, with: "status")
            }
            HStack {
                form(for: character.species, with: "species")
                form(for: character.type, with: "type")
                    .minimumScaleFactor(0.6)
            }
            form(for: character.location?.name ?? "no location found", with: "location")
            form(for: character.created, with: "created")
            
            Text("Episodes:")
                .foregroundStyle(Color.gray)
                .padding(.top, 5)
            VStack(alignment: .leading) {
                ForEach(characterVM.episodes, id: \.self) { episode in
                    Text(episode.name)
                        .font(.title3)
                    Text(episode.episode)
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                    Divider()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
            }
            .padding(5)
        }
        .toolbar(.hidden, for: .tabBar)
        .task {
            for url in character.episode {
                do {
                    try await characterVM.getExtraInfo(with: url)
                } catch {
                    self.alert = AppError.badURL
                }
            }
        }
    }
}

#Preview {
    CharacterDetailView(characterVM: CharactersViewModel(apiManger: APIManager()), character: DeveloperPreview.instanse.charackter)
}

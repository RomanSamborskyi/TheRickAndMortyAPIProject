//
//  CharackterPresentationView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI

struct CharackterPresentationView: View {
    
    let character: Character
    var characterStatus: String {
        if character.status == "Alive" {
            return character.status + " " + "🟢"
        } else {
            return character.status + " " + "🔴"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            CharacterImageView(imageURL: character.image, imageID: String(character.id))
                .padding(5)
                .frame(width: 180, height: 180)
            Text(character.name)
                .padding(.leading)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Divider()
                .frame(width: 180)
            Text(characterStatus)
                .padding(.leading)
                .padding(.bottom)
        }
        .padding(0.5)
        .background(
         RoundedRectangle(cornerRadius: 25)
            .stroke(lineWidth: 3)
            .foregroundStyle(Color.black)
        )
    }
}

#Preview {
    CharackterPresentationView(character: DeveloperPreview.instanse.charackter)
}

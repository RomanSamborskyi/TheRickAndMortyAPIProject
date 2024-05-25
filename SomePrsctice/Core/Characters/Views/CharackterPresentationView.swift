//
//  CharackterPresentationView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI

struct CharackterPresentationView: View {
    
    let character: Character
    
    var body: some View {
        VStack(alignment: .leading) {
            CharacterImageView(imageURL: character.image, imageID: String(character.id))
                .frame(width: 200, height: 200)
            Text(character.name)
                .padding(.leading)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
        }
    }
}

#Preview {
    CharackterPresentationView(character: DeveloperPreview.instanse.charackter)
}

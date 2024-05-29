//
//  CharacterImageView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI

struct CharacterImageView: View {
    
    @StateObject var downloader: ImageDownloader
    let imageURL: String
    let imageID: String
    
    init(imageURL: String, imageID: String) {
        self.imageURL = imageURL
        self.imageID = imageID
        
        _downloader = StateObject(wrappedValue: ImageDownloader(imageURL: imageURL, imageID: imageID))
    }
    
    var body: some View {
        VStack {
            if downloader.isLoading {
                ProgressView()
                    .background(RoundedRectangle(cornerRadius: 20)
                        .frame(width: 180, height: 180)
                        .foregroundStyle(Color.gray.opacity(0.4))
                    )
                    .padding()
            } else {
                if let image = downloader.poster {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
    }
}

#Preview {
    CharacterImageView(imageURL: DeveloperPreview.instanse.charackter.image, imageID: String(DeveloperPreview.instanse.charackter.id))
}

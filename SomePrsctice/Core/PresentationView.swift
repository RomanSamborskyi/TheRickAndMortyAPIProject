//
//  PresentationView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 30.05.2024.
//

import SwiftUI

struct PresentationView<T>: View {
    
    let item: T
    let gradient: LinearGradient = LinearGradient(colors: [.blue, .black, .black, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack {
            if let episode = item as? Episode {
                EpisodePresentationGenericView(episode: episode, gradient: gradient)
            } else if let location = item as? SingleLocation {
                LocationPresentationGenericView(location: location, gradient: gradient)
            }
        }
    }
}

#Preview {
    PresentationView(item: DeveloperPreview.instanse.episode)
}


struct EpisodePresentationGenericView: View {
    
    let episode: Episode
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("name:")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                Text(episode.name)
                    .font(.title2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Divider()
            HStack {
                Text("episode:")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                Text(episode.episode)
                    .font(.callout)
                    
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 3)
                .foregroundStyle(gradient)
        )
        .padding(5)
    }
}

struct LocationPresentationGenericView: View {
    
    let location: SingleLocation
    let gradient: LinearGradient
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("name:")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                Text(location.name)
                    .font(.title2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Divider()
            HStack {
                Text("dimension:")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                Text(location.dimension)
                    .font(.callout)
                    
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 3)
                .foregroundStyle(gradient)
        )
        .padding(5)
    }
}

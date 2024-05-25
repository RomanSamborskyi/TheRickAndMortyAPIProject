//
//  EpisodeDetailView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 25.05.2024.
//

import SwiftUI

struct EpisodeDetailView: View {
    
    @State private var alert: AppError? = nil
    @ObservedObject var vm: EpisodesViewModel
    @State private var gridItem: [GridItem] = [GridItem(), GridItem()]
    let episode: Episode
    
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
            Text(episode.name)
                .padding()
                .font(.largeTitle)
                .fontWeight(.bold)
            VStack {
                makeHStack(for: episode.episode, with: "Episode")
                makeHStack(for: episode.airDate, with: "Air date")
                makeHStack(for: episode.created, with: "Created")
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
            LazyVGrid(columns: gridItem) {
                ForEach(vm.characters, id: \.self) { character in
                    CharackterPresentationView(character: character)
                }
            }
        }
        .task {
            do {
                for url in episode.characters {
                    try await vm.getExtraInfo(with: url)
                }
            } catch {
                self.alert = AppError.badURL
            }
        }
    }
}

#Preview {
    EpisodeDetailView(vm: EpisodesViewModel(apiManager: APIManager()), episode: DeveloperPreview.instanse.episode)
}

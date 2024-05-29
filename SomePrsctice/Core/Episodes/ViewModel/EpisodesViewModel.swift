//
//  EpisodesViewModel.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import Foundation



class EpisodesViewModel: ObservableObject {
    
    @Published var episodes: [Episode] = []
    @Published var characters: [Episode : [Character]] = [:]
    @Published var episodesForCharacter: [Character : [Episode]] = [:]
    @Published var nextURL: String? = nil
    
    let apiManager: APIManager
    
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    
    ///Func to get episodes for specific character
    func getEpisodes(for character: Character) async throws {
        
        let result = try await withThrowingTaskGroup(of: Episode.self) { group in
            var episodes: [Episode] = []
            
            for episodeURL in character.episode {
                guard let url = URL(string: episodeURL) else {
                    throw AppError.badURL
                }
                
                group.addTask {
                    guard let episode = try await self.apiManager.download(with: url, type: Episode.self) else {
                        throw URLError(.dataNotAllowed)
                    }
                    return episode
                }
                for try await item in group {
                    episodes.append(item)
                }
            }
            return episodes
        }
        await MainActor.run {
            self.episodesForCharacter[character] = result
        }
    }
    ///Func to get characters fot current episode
    func getExtraInfo(for episode: Episode) async throws {

        let result = try await withThrowingTaskGroup(of: Character.self) { group in
            var characters: [Character] = []
            
            for url in episode.characters {
                guard let url = URL(string: url) else {
                    throw AppError.badURL
                }
                
                group.addTask {
                    guard let character = try await self.apiManager.download(with: url, type: Character.self) else {
                        throw URLError(.dataNotAllowed)
                    }
                    return character
                }
                
                for try await item in group {
                    characters.append(item)
                }
            }
            return characters
        }
        await MainActor.run {
            self.characters[episode] = result
        }
    }
    ///Func to get episodes list
    func getEpisodes(with url: String) async throws {
        
        guard let url = URL(string: url) else {
            throw AppError.badURL
        }
        
        try await withThrowingTaskGroup(of: EpisodesResponse.self) { group in
            
            group.addTask {
                try await self.apiManager.download(with: url, type: EpisodesResponse.self)!
            }
            
            for try await episode in group {
                await MainActor.run {
                    self.episodes.append(contentsOf: episode.results)
                    if episode.info.next != nil {
                        self.nextURL = episode.info.next
                    } else if episode.info.next == nil {
                        self.nextURL = nil
                    }
                }
            }
        }
    }
    ///Return search URL
    func search(episode: String) -> String? {
        return "\(APIEpisodesEndpoints.baseURl.endpoints)?name=\(episode)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
    }
}

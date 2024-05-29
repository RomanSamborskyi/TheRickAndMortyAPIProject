//
//  EpisodesViewModel.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import Foundation



class EpisodesViewModel: ObservableObject {
    
    @Published var episodes: [Episode] = []
    @Published var characters: [Episode:[Character]] = [:]
    @Published var nextURL: String? = nil
    
    let apiManager: APIManager
    
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    
    ///Func to get characters fot current episode
    func getExtraInfo(for episode: Episode) async throws {
        var array:[Character] = []
        for url in episode.characters {
            guard let url = URL(string: url) else {
                throw AppError.badURL
            }
           
            if let character = try await apiManager.download(with: url, type: Character.self) {
                array.append(character)
            }
            DispatchQueue.main.async {
                self.characters[episode] = array
            }
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

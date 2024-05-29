//
//  CharactersViewModel.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import Foundation


class CharactersViewModel: ObservableObject {
    
    @Published var characters: [Character] = []
    @Published var episodes: [Character : [Episode]] = [:]
    @Published var charactersForEpisode: [Episode : [Character]] = [:]
    @Published var nextURL: String? = nil
    
    let manager: APIManager
    
    init(apiManger: APIManager) {
        self.manager = apiManger
    }
    
    
    ///Func to fetch characters with specific url
    func getCharacters(with url: String) async throws {
        
        guard let url = URL(string: url) else {
            throw AppError.badURL
        }
        
        try await withThrowingTaskGroup(of: CharacterResponse.self) { character in
            character.addTask {
                try await self.manager.download(with: url, type: CharacterResponse.self)!
            }
            
            for try await response in character {
                await MainActor.run {
                    self.characters.append(contentsOf: response.results)
                    if response.info.next != nil {
                        self.nextURL = response.info.next
                    } else if response.info.next == nil {
                        self.nextURL = nil
                    }
                }
            }
        }
    }
    ///Func to creat url for filter charactres
    func filterUrl(status: FilterCharactersStatus?, gender: FilterCharactersGender?) -> String? {
        if let status = status, status != .non, let gender = gender, gender != .non {
            return "\(APICharactersEndpoints.baseURL(endpoint: .non).endpoints)?\(status.endpoints)&\(gender.endpoints)"
        } else if let status = status, gender == .non {
            return "\(APICharactersEndpoints.baseURL(endpoint: .non).endpoints)?\(status.endpoints)"
        } else if let gender = gender, status == .non {
            return "\(APICharactersEndpoints.baseURL(endpoint: .non).endpoints)?\(gender.endpoints)"
        }
        return nil
    }
    ///Search url func
    func search(with name: String) -> String? {
        return APICharactersEndpoints.baseURL(endpoint: .name(name)).endpoints.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
    }
    ///Func to get locations for character
    func getEpisodes(for character: Character) async throws {
        
        var array: [Episode] = []
        
        for url in character.episode {
            guard let url = URL(string: url) else {
                throw AppError.badURL
            }
            if let episode = try await self.manager.download(with: url, type: Episode.self) {
                array.append(episode)
            }
        }
            DispatchQueue.main.async {
                self.episodes[character] = array
            }
        
    }
    ///Func to get characters for specific episode
    func getCharacter(for episode: Episode) async throws {
        
        var characters: [Character] = []
        
        for characterURL in episode.characters {
            
            guard let url = URL(string: characterURL) else {
                throw AppError.badURL
            }
            
            if let character = try await manager.download(with: url, type: Character.self) {
                characters.append(character)
            }
        }
        
        DispatchQueue.main.async {
            self.charactersForEpisode[episode] = characters
        }
    }
}

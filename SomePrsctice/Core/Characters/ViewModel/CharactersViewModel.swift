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
                guard let characters = try await self.manager.download(with: url, type: CharacterResponse.self) else {
                    throw URLError(.dataNotAllowed)
                }
                return characters
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
    ///Func to get episodes for character
    func getEpisodes(for character: Character) async throws {
        
        let result = try await withThrowingTaskGroup(of: Episode.self) { group in
            var array: [Episode] = []
            
            for url in character.episode {
                
                guard let url = URL(string: url) else {
                    throw AppError.badURL
                }
                
                group.addTask {
                    guard let episode = try await self.manager.download(with: url, type: Episode.self) else {
                        throw URLError(.dataNotAllowed)
                    }
                    return episode
                }
                
                for try await item in group {
                    array.append(item)
                }
            }
            return array
        }
        
        await MainActor.run {
            self.episodes[character] = result
        }
    }
    ///Func to get characters for specific episode
    func getCharacter(for episode: Episode) async throws {
        
        let result = try await withThrowingTaskGroup(of: Character.self) { charackter in
            
            for characterURL in episode.characters {
                
                guard let url = URL(string: characterURL) else {
                    throw AppError.badURL
                }
                charackter.addTask {
                    guard let character = try await self.manager.download(with: url, type: Character.self) else { throw URLError(.unknown) }
                    return character
                }
            }
            var characters: [Character] = []
            
            for try await item in charackter {
                characters.append(item)
            }
            return characters
        }
        
        await MainActor.run {
            self.charactersForEpisode[episode] = result
        }
    }
}

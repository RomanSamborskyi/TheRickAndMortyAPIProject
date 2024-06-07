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
    @Published var locationForCharacter: [Character : SingleLocation] = [:]
    @Published var charactersForLocation: [SingleLocation : [Character]] = [:]
    @Published var charactersForEpisode: [Episode : [Character]] = [:]
    @Published var nextURL: String? = nil
    
    let apiManager: APIManager
    
    init(apiManger: APIManager) {
        self.apiManager = apiManger
    }
    
    
    
    
    ///Func to fetch characters for location
    func fetchCharacters(for location: SingleLocation) async throws {
        
        let characters = try await withThrowingTaskGroup(of: Character.self) { group in
            
            for url in location.residents {
                guard let url = URL(string: url) else { throw AppError.badURL }
               group.addTask {
                    guard let character = try await self.apiManager.download(with: url, type: Character.self) else {
                        throw AppError.badResponse(status: nil)
                    }
                    return character
                }
                try await Task.sleep(for: .seconds(0.03))
            }
            
            var characters: [Character] = []
            
            for try await character in group {
                characters.append(character)
            }
            return characters
        }
        await MainActor.run {
            self.charactersForLocation[location] = characters
        }
    }
    
    ///Func to fetch characters with specific url
    func getCharacters(with url: String) async throws {
        
        guard let url = URL(string: url) else {
            throw AppError.badURL
        }
        
        try await withThrowingTaskGroup(of: CharacterResponse.self) { group in
            
            group.addTask { [unowned self] in
                guard let characters = try await self.apiManager.download(with: url, type: CharacterResponse.self) else {
                    throw URLError(.dataNotAllowed)
                }
                return characters
            }
            
            for try await response in group {
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
        
        let episodes = try await withThrowingTaskGroup(of: Episode.self) { group in
            
            for url in character.episode {
                
                guard let url = URL(string: url) else {
                    throw AppError.badURL
                }
                
                group.addTask { [unowned self] in
                    guard let episode = try await self.apiManager.download(with: url, type: Episode.self) else {
                        throw URLError(.dataNotAllowed)
                    }
                    return episode
                }
            }
            
            var array: [Episode] = []
            
            for try await item in group {
                array.append(item)
            }
            return array
        }
        
        let location = try await withThrowingTaskGroup(of: SingleLocation.self) { group in
            
            guard let url = URL(string: character.location?.url ?? "") else {
                throw AppError.badURL
            }
            
            group.addTask { [unowned self] in
                guard let location = try await self.apiManager.download(with: url, type: SingleLocation.self) else {
                    throw URLError(.dataNotAllowed)
                }
                return location
            }
            
            var location: SingleLocation? = nil
            
            for try await loc in group {
                location = loc
            }
            return location
        }
        
        
        await MainActor.run {
            self.episodes[character] = episodes
            self.locationForCharacter[character] = location
        }
    }
    ///Func to get characters for specific episode
    func getCharacter(for episode: Episode) async throws {
        
        let result = try await withThrowingTaskGroup(of: Character.self) { group in
            
            for characterURL in episode.characters {
                
                guard let url = URL(string: characterURL) else {
                    throw AppError.badURL
                }
                
                group.addTask { [unowned self] in
                    guard let character = try await self.apiManager.download(with: url, type: Character.self) else { throw URLError(.unknown) }
                    return character
                }
            }
            
            var characters: [Character] = []
            
            for try await item in group {
                characters.append(item)
            }
            return characters
        }
        
        await MainActor.run {
            self.charactersForEpisode[episode] = result
        }
    }
}

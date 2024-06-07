//
//  LocationsViewModel.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import Foundation



class LocationsViewModel: ObservableObject {
    
    @Published var locations: [SingleLocation] = []
    @Published var episodes: [Character : [Episode]] = [:]
    @Published var locationForCharacter: [Character : SingleLocation] = [:]
    @Published var characters: [Episode : [Character]] = [:]
    @Published var charactersForLocation: [SingleLocation : [Character]] = [:]
    @Published var residentsForLocation: [SingleLocation : [Character]] = [:]
    @Published var nextURL: String? = nil
    
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    ///Func to fetch characters for location
    func fetchCharacters(for location: SingleLocation) async throws {
        
        let characters = try await withThrowingTaskGroup(of: Character.self) { group in
            for url in location.residents {
                guard let url = URL(string: url) else { throw AppError.badURL }
                
                group.addTask { [unowned self] in
                    guard let character = try await self.apiManager.download(with: url, type: Character.self) else {
                        throw URLError(.dataNotAllowed)
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
    ///Search func
    func search(with text: String) -> String? {
        return "\(APILocationEndpoints.baseURl.endpoints)?name=\(text)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
    }
    
    ///Func to get characters fot current episode
    func getExtraInfo(for episode: Episode) async throws {

        let result = try await withThrowingTaskGroup(of: Character.self) { group in
            var characters: [Character] = []
            
            for url in episode.characters {
                guard let url = URL(string: url) else {
                    throw AppError.badURL
                }
                
                group.addTask { [unowned self] in
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
    ///Func to get episodes for character
    func getEpisodes(for character: Character) async throws {
        
        let episodes = try await withThrowingTaskGroup(of: Episode.self) { group in
            var array: [Episode] = []
            
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
                
                for try await item in group {
                    array.append(item)
                }
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
    ///Func to get characters for location
    func getCharacters(for location: SingleLocation) async throws {
        let result = try await withThrowingTaskGroup(of: Character.self) { group in
            for url in location.residents {
                guard let url = URL(string: url) else {
                    throw AppError.badURL
                }
                
                group.addTask { [unowned self] in
                    guard let resident = try await self.apiManager.download(with: url, type: Character.self) else {
                        throw URLError(.dataNotAllowed)
                    }
                    return resident
                }
            }
            
            var residents: [Character] = []
            
            for try await resident in group {
                residents.append(resident)
            }
            return residents
        }
        
        await MainActor.run {
            self.residentsForLocation[location] = result
        }
    }
    ///Func to fetch all Locations
    func getLocations(with url: String) async throws {
        
        guard let url = URL(string: url) else {
            throw AppError.badURL
        }
       
        try await withThrowingTaskGroup(of: LocationRsponse.self) { group in
            group.addTask { [unowned self] in
                guard let location = try await self.apiManager.download(with: url, type: LocationRsponse.self) else {
                    throw URLError(.dataNotAllowed)
                }
                return location
            }
            
            for try await response in group {
                await MainActor.run {
                    self.locations.append(contentsOf: response.results)
                    if response.info.next != nil {
                        self.nextURL = response.info.next
                    } else if response.info.next == nil {
                        self.nextURL = nil
                    }
                }
            }
        }
    }
}

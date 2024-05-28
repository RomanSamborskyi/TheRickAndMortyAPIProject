//
//  CharactersViewModel.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import Foundation


class CharactersViewModel: ObservableObject {
    
    @Published var characters: [Character] = []
    @Published var episodes: [Episode] = [] 
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
        
        try await withThrowingTaskGroup(of: CharacterResponse.self) { group in
            group.addTask {
                try await self.manager.download(with: url, type: CharacterResponse.self)!
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
    ///Func to get locations for character
    func getExtraInfo(with url: String) async throws {
        
        guard let url = URL(string: url) else { 
            throw AppError.badURL
        }
        
        try await withThrowingTaskGroup(of: Episode.self) { group in
            group.addTask {
                try await self.manager.download(with: url, type: Episode.self)!
            }
            
            for try await result in group {
                await MainActor.run {
                    self.episodes.append(result)
                }
            }
        }
    }
}

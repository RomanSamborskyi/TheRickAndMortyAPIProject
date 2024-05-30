//
//  Enums.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 24.05.2024.
//

import Foundation


enum FilterCharactersStatus: String,  CaseIterable {
    
    case non, alive, dead, unknown
    
    var endpoints: String {
        switch self {
        case .alive:
            "status=\(self.rawValue)"
        case .dead:
            "status=\(self.rawValue)"
        case .unknown:
            "status=\(self.rawValue)"
        case .non:
            ""
        }
    }
}

enum FilterCharactersGender: String, CaseIterable {
    case non, female, male, genderless, unknown
    
    var endpoints: String {
        switch self {
        case .female:
            "gender=\(self.rawValue)"
        case .male:
            "gender=\(self.rawValue)"
        case .genderless:
            "gender=\(self.rawValue)"
        case .unknown:
            "gender=\(self.rawValue)"
        case .non:
            ""
        }
    }
}

enum APICharactersEndpoints {
    case singleCharacter(id: Int)
    case allCahracters(page: Int = 1)
    indirect case baseURL(endpoint:APICharactersEndpoints)
    case name(String)
    case non
    
    var endpoints: String {
        switch self {
        case .singleCharacter(let id):
            "\(id)"
        case .allCahracters(let page):
            "?page=\(page)"
        case .baseURL(let endpoint):
            "https://rickandmortyapi.com/api/character/\(endpoint.endpoints)"
        case .name(let name):
            "?name=\(name)"
        case .non:
            ""
        }
    }
}

enum APIEpisodesEndpoints {
    case baseURl
    
    var endpoints: String {
        switch self {
        case .baseURl:
            "https://rickandmortyapi.com/api/episode/"
        }
    }
}

enum APILocationEndpoints {
    case baseURl
    
    var endpoints: String {
        switch self {
        case .baseURl:
            "https://rickandmortyapi.com/api/location"
        }
    }
}



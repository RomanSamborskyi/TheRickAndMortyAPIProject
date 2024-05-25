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
    case singleCharacter(id: Int), allCahracters(page: Int = 1)
    
    var endpoints: String {
        switch self {
        case .singleCharacter(let id):
            "https://rickandmortyapi.com/api/character/\(id)"
        case .allCahracters(let page):
            "https://rickandmortyapi.com/api/character/?page=\(page)"
        }
    }
}

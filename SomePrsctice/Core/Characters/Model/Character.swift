//
//  Character.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import Foundation

struct CharacterResponse: Codable {
    
    let info: Info
    let results: [Character]
}

struct Info: Codable {
    
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct Character: Identifiable, Codable, Hashable {
    
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: Location?
    let location: Location?
    let image: String
    let episode: [String]
    let url: String
    let created: String
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }
}

struct Location: Codable, Hashable {
    let name: String?
    let url: String?
}

//
//  Episode.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import Foundation


struct EpisodesResponse: Codable {
    let info: Info
    let results: [Episode]
}

struct Episode: Identifiable, Codable, Hashable {
    
    let id: Int
    let name, airDate, episode: String
    let characters: [String]
    let url: String
    let created: String
    
    enum CodingKeys: String, CodingKey {
         case id, name
         case airDate = "air_date"
         case episode, characters, url, created
     }
}

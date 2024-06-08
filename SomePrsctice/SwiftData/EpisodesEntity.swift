//
//  EpisodesEntity.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 08.06.2024.
//

import Foundation
import SwiftData


@Model
class EpisodesEntity {
    let id: Int
    let name: String
    let airDate: String
    var episode: String
    let characters: String?
    let url: String
    let created: String
    
    init(id: Int, name: String, airDate: String, episode: String, characters: String? = nil, url: String, created: String) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.episode = episode
        self.characters = characters
        self.url = url
        self.created = created
    }
}

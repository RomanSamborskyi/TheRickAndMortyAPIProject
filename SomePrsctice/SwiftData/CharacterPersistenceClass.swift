//
//  CharacterPersistenceClass.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 08.06.2024.
//

import SwiftUI
import SwiftData

@Model
class CharacterEntity {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let location: String?
    let image: String
    let created: String
    
    init(id: Int, name: String, status: String, species: String, type: String, gender: String, location: String?, image: String, created: String) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.location = location
        self.image = image
        self.created = created
    }
}

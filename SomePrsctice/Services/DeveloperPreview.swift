//
//  DeveloperPreview.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import Foundation


class DeveloperPreview {
    
    static let instanse: DeveloperPreview = DeveloperPreview()
    
    private init() {  }
    
    let charackter: Character = Character(id: 2, name: "Morty Smith", status: "Alive", species: "Human", type: "", gender: "Male", origin: nil, location: nil, image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg", episode: ["https://rickandmortyapi.com/api/episode/1","https://rickandmortyapi.com/api/episode/2"], url: "https://rickandmortyapi.com/api/character/2", created: "2017-11-04T18:50:21.651Z")
    
    let episode: Episode = Episode(id: 1, name: "Pilot", airDate: "December 2, 2013", episode: "S01E01", characters: [
        "https://rickandmortyapi.com/api/character/1",
        "https://rickandmortyapi.com/api/character/2",
    ], url: "https://rickandmortyapi.com/api/episode/1", created: "2017-11-10T12:56:33.798Z")
    
    let locaton: SingleLocation = SingleLocation(id: 1, name: "Earth", type: "Planet", dimension: "Dimension C-137", residents: [
        "https://rickandmortyapi.com/api/character/1",
        "https://rickandmortyapi.com/api/character/2",
    ], url: "https://rickandmortyapi.com/api/location/1", created: "2017-11-10T12:42:04.162Z")
}

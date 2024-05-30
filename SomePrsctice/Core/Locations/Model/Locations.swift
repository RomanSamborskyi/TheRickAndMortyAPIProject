//
//  Locations.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 30.05.2024.
//

import Foundation

struct LocationRsponse: Codable {
    let info: Info
    let results: [SingleLocation]
}

struct SingleLocation: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [String]
    let url: String
    let created: String
}

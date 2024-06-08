//
//  LocationEntity.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 08.06.2024.
//

import Foundation
import SwiftData


@Model
class LocationEntity {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: String?
    let url: String
    let created: String
    
    init(id: Int, name: String, type: String, dimension: String, residents: String? = nil, url: String, created: String) {
        self.id = id
        self.name = name
        self.type = type
        self.dimension = dimension
        self.residents = residents
        self.url = url
        self.created = created
    }
}

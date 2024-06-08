//
//  AnimatedTabBar.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 01.06.2024.
//

import Foundation



enum Tabs: String, CaseIterable {
    case characters, episodes, locations, saved
    
    var description: String {
        switch self {
        case .characters:
            return "Characters"
        case .episodes:
            return "Episodes"
        case .locations:
            return "Locations"
        case .saved:
            return "Saved"
        }
    }
    
    var images: String {
        switch self {
        case .characters:
            return "person.fill"
        case .episodes:
            return "tv"
        case .locations:
            return "globe"
        case .saved:
            return "bookmark.circle"
        }
    }
}


struct AnimatedTabBar: Identifiable {
    var id: UUID = .init()
    var tab: Tabs
    var isAnimating: Bool?
}

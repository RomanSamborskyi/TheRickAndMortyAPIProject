//
//  SomePrscticeApp.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI
import SwiftData

@main
struct SomePrscticeApp: App {
    
    var container: ModelContainer
    
    init() {
        do {
            let config1 = ModelConfiguration(for: CharacterEntity.self, EpisodesEntity.self, LocationEntity.self)
            
            container = try ModelContainer(for: CharacterEntity.self, EpisodesEntity.self, LocationEntity.self, configurations: config1)
        } catch {
            fatalError("Error of configing SwifData containers")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CharacterEntity.self, EpisodesEntity.self, LocationEntity.self])
    }
}

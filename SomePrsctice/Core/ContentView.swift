//
//  ContentView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var tabs: Tabs = .characters
    
    var body: some View {
        ZStack {
            switch tabs {
            case .characters:
                CharactersMainView()
            case .episodes:
                EpisodesMainView()
            case .locations:
                LocationsMainView()
            case .saved:
                SavedItemsMainView()
            }
            CustomTabBarView(activeTab: $tabs)
        }
    }
}

#Preview {
    ContentView()
}

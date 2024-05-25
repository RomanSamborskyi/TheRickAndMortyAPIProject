//
//  ContentView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CharactersMainView()
                .tabItem {
                    Label(
                        title: { Text("Characters") },
                        icon: { Image(systemName: "person") }
                    )
                }
            EpisodesMainView()
                .tabItem {
                    Label(
                        title: { Text("Episodes") },
                        icon: { Image(systemName: "tv") }
                    )
                }
            LocationsMainView()
                .tabItem {
                    Label(
                        title: { Text("Locations") },
                        icon: { Image(systemName: "globe") }
                    )
                }
        }
    }
}

#Preview {
    ContentView()
}

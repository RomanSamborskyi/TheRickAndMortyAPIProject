//
//  DebouncedResult.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 01.06.2024.
//

import SwiftUI
import Combine


class DebouncedResult: ObservableObject {
    @Published var searchText: String = ""
    var debounceCancellable: AnyCancellable?
    
    init() {
        debounceCancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { _ in
                
            }
    }
}

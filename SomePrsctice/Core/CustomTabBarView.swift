//
//  CustomTabBarView.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 01.06.2024.
//

import SwiftUI

struct CustomTabBarView: View {
    
    @Binding var activeTab: Tabs
    @State private var allTabs: [AnimatedTabBar] = Tabs.allCases.compactMap { tab -> AnimatedTabBar? in
           return .init(tab: tab)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 0)
                        .frame(width: proxy.size.width, height: proxy.size.height / 9)
                        .foregroundStyle(Material.thin)
                    HStack(spacing: proxy.size.width / 8.5) {
                        ForEach($allTabs) { $tab in
                            let currentTab = tab.tab
                            VStack {
                                Image(systemName: currentTab.images)
                                    .symbolEffect(.bounce, value: tab.isAnimating)
                                    .font(.title2)
                                    .padding(3)
                                Text(currentTab.description)
                                    .font(.caption2)
                            }
                            .foregroundStyle(self.activeTab == currentTab ? Color.accentColor : Color.gray)
                            .onTapGesture {
                                withAnimation(.bouncy, completionCriteria: .logicallyComplete) {
                                    self.activeTab = currentTab
                                    tab.isAnimating = true
                                } completion: {
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        tab.isAnimating = nil
                                    }
                                }
                            }
                        }
                    }
                    .padding(5)
                }
            }
            .ignoresSafeArea(.all, edges: .all)
        }
    }
}


#Preview {
    ContentView()
}

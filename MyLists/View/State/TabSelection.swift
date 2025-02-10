//
//  TabSelection.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 13/10/2024.
//

import Foundation

class TabSelection: ObservableObject {
    @Published var selectedTab: Int = 1
    @Published private(set)var shouldPopToRootView: Bool = false
    
    func select(tab: Int, shouldPopToRootView: Bool = false) {
        self.selectedTab = tab
        self.shouldPopToRootView = shouldPopToRootView
    }
    
    func didPopToRootView() {
        shouldPopToRootView = false
    }
}

extension TabSelection: Equatable {
    static func == (lhs: TabSelection, rhs: TabSelection) -> Bool {
        lhs.selectedTab == rhs.selectedTab && lhs.shouldPopToRootView == rhs.shouldPopToRootView
    }
}

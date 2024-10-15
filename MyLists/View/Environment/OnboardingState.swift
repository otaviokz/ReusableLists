//
//  OnboardingState.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 13/10/2024.
//

import Foundation
import SwiftUI

class OnboardingState: ObservableObject {
//    @Published private(set)var completed: Bool
    var completed: Binding<Bool>? {
        didSet {
            completed?.wrappedValue = SettingsManager.shared.isOnboardingComplete
        }
    }
    
    init() {
//        self.completed = SettingsManager.shared.isOnboardingComplete
        self.completed?.wrappedValue = SettingsManager.shared.isOnboardingComplete
    }
    
    func didComplete() {
//        completed = true
        SettingsManager.shared.setIsOnbardingComplete(true)
        completed?.wrappedValue = true
    }
    
    func reset() {
//        completed = false
        SettingsManager.shared.setIsOnbardingComplete(false)
        completed?.wrappedValue = false
    }
}

//
//  OnboardingState.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 13/10/2024.
//

import Foundation
import SwiftUI

class OnboardingState: ObservableObject {
    var completed: Binding<Bool>? {
        didSet {
            completed?.wrappedValue = SettingsManager.shared.isOnboardingComplete
        }
    }
    
    init() {
        self.completed?.wrappedValue = SettingsManager.shared.isOnboardingComplete
    }
    
    func didComplete() {
        SettingsManager.shared.setIsOnbardingComplete(true)
        completed?.wrappedValue = true
    }
    
    func reset() {
        SettingsManager.shared.setIsOnbardingComplete(false)
        completed?.wrappedValue = false
    }
}

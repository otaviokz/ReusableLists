//
//  OnboardingState.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 13/10/2024.
//

import Foundation
import SwiftUI

class OnboardingState: ObservableObject {
    private var userPreferences = UserDefaults.standard
        
    var completed: Binding<Bool>? {
        didSet {
            completed?.wrappedValue = userPreferences.bool(
                forKey: Keys.onboarded
            )
        }
    }
    
    init() {
        self.completed?.wrappedValue = userPreferences.bool(
            forKey: Keys.onboarded
        )
    }
    
    func didComplete() {
        userPreferences.setValue(true, forKey: Keys.onboarded)
        completed?.wrappedValue = true
    }
    
    func reset() {
        userPreferences.setValue(false, forKey: Keys.onboarded)
        completed?.wrappedValue = false
    }
}

private extension OnboardingState {
    struct Keys {
        static var onboarded: String { "isOnboardingShown" }
    }
}

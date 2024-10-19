//
//  UserPreferencesManager.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 11/10/2024.
//

import Foundation
import Combine

class SettingsManager {
    @Published private(set)var isOnboardingComplete: Bool
    
    static var shared = SettingsManager()
    
    private var userPreferences = UserDefaults.standard
    
    private init() {
        self.isOnboardingComplete = userPreferences.bool(forKey: Keys.isOnboardingComplete)
    }
    
    func setIsOnbardingComplete(_ complete: Bool) {
        userPreferences.setValue(complete, forKey: Keys.isOnboardingComplete)
        isOnboardingComplete = complete
    }
}

private extension SettingsManager {
    struct Keys {
        static var isOnboardingComplete: String { "isOnboardingShown" }
    }
}

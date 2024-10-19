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
    // Creating Blueprints from Lists is not part of the app's functionalities,
    // but can be made available for testing purposes¹
//    @Published private(set)var addBlueprintFromListEnabled: Bool = false
    
    static var shared = SettingsManager()
    
    private var userPreferences = UserDefaults.standard
    
    private init() {
        self.isOnboardingComplete = userPreferences.bool(forKey: Keys.isOnboardingComplete)
//        self.hideAddBluetrpintFromList()
    }
    
    func setIsOnbardingComplete(_ complete: Bool) {
        userPreferences.setValue(complete, forKey: Keys.isOnboardingComplete)
        isOnboardingComplete = complete
    }
    
//    func hideAddBluetrpintFromList() {
//        userPreferences.setValue(false, forKey: Keys.showAddBluetrpintFromList)
//    }
//    
//    func flipShowAddBluetrpintFromList() {
//        addBlueprintFromListEnabled = !addBluePrinFromListVisible()
//    }
//    
//    func addBluePrinFromListVisible() -> Bool {
//        userPreferences.bool(forKey: Keys.showAddBluetrpintFromList)
//    }
}

private extension SettingsManager {
    struct Keys {
        static var isOnboardingComplete: String { "isOnboardingShown" }
        static var showAddBluetrpintFromList: String { "showAddBluetrpintFromList" }
    }
}

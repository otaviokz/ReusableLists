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
    @Published private(set)var showAddBluetrpintFromList: Bool = false
    
    static var shared = SettingsManager()
    
    private var userPreferences = UserDefaults.standard
    
    private init() {
        self.isOnboardingComplete = userPreferences.bool(forKey: Keys.isOnboardingComplete)
        self.hideAddBluetrpintFromList()
    }
    
    func setIsOnbardingComplete(_ complete: Bool) {
        userPreferences.setValue(complete, forKey: Keys.isOnboardingComplete)
        isOnboardingComplete = complete
    }
    
    func hideAddBluetrpintFromList() {
        userPreferences.setValue(false, forKey: Keys.showAddBluetrpintFromList)
    }
    
    func flipShowAddBluetrpintFromList() -> Bool {
        userPreferences.setValue(showAddBluetrpintFromList.toggle(), forKey: Keys.showAddBluetrpintFromList)
        return userPreferences.bool(forKey: Keys.showAddBluetrpintFromList)
    }
//    
//    func setAddBluetprintFromListVisible(_ show: Bool) {
//        showAddBluetrpintFromList = show
//        userPreferences.setValue(show, forKey: Keys.showAddBluetrpintFromList)
//    }
}

private extension SettingsManager {
    struct Keys {
        static var isOnboardingComplete: String { "isOnboardingShown" }
        static var showAddBluetrpintFromList: String { "showAddBluetrpintFromList" }
    }
}

//
//  FinalVersionUpdate.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 16/10/2026.
//

import Foundation

/// Tracks, via `UserDefaults.standard`, whether the app is being launched
/// for the first time since updating to the final version (3.0.0).
struct FinalVersionUpdate {
    static let finalVersion = "3.0.0"
    
    private let userPreferences = UserDefaults.standard
    
    /// `true` while no value has been stored yet, i.e. the final version notice was never shown.
    var isFirstLaunchAfterUpdate: Bool {
        userPreferences.string(forKey: Keys.lastLaunchedVersion) == nil
    }
    
    /// Users who completed onboarding before have been using an older version,
    /// as opposed to fresh installs of the final version.
    var isUpdatingFromOlderVersion: Bool {
        userPreferences.bool(forKey: Keys.onboarded)
    }
    
    /// Records that the final version notice has been shown, so `isFirstLaunchAfterUpdate` returns `false` from now on.
    func markAsSeen() {
        userPreferences.set(Self.finalVersion, forKey: Keys.lastLaunchedVersion)
    }
}

extension FinalVersionUpdate {
    static var noticeTitle: String { "Final Update" }
    
    static var noticeMessage: String {
        "This is the last update published for Reusable Lists. Soon you'll be able to export all your data to the new app. Please read the instructions in the About page."
    }
}

private extension FinalVersionUpdate {
    struct Keys {
        static var lastLaunchedVersion: String { "lastLaunchedVersion" }
        /// Same key used by `OnboardingState`.
        static var onboarded: String { "isOnboardingShown" }
    }
}

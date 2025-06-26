//
//  OnboardingParameters.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 18/03/25.
//

import SwiftUI

/// A class responsible for tracking and persisting the user's onboarding completion status.
///
/// This observable class stores the onboarding state using `UserDefaults` under a predefined key.
/// It can be used throughout the app to conditionally show onboarding screens or skip them if the user has already completed the process.
@Observable
class OnboardingParameters {

    /// Indicates whether the user has completed onboarding.
    ///
    /// This value is loaded from and stored to `UserDefaults` to persist across app launches.
    var completed: Bool

    /// The `UserDefaults` key used to store the onboarding status.
    private let onboardingStatusKey = "OnboardingStatus"

    /// Initializes a new instance of `OnboardingParameters`.
    ///
    /// The onboarding completion status is retrieved from `UserDefaults` using a fixed key.
    init() {
        self.completed = UserDefaults.standard.bool(forKey: onboardingStatusKey)
    }

    /// Saves the onboarding completion status to `UserDefaults`.
    ///
    /// This method sets `completed` to `true` and persists it using the predefined key.
    /// It should be called once the onboarding process has been successfully completed by the user.
    func saveCompletionValue() {
        self.completed = true
        UserDefaults.standard.set(true, forKey: onboardingStatusKey)
    }
}

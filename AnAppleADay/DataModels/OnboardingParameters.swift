//
//  OnboardingParameters.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 18/03/25.
//

import SwiftUI

@Observable
class OnboardingParameters {
    var completed: Bool

    private let onboardingStatusKey = "OnboardingStatus"

    init() {
        self.completed = UserDefaults.standard.bool(forKey: onboardingStatusKey)
    }

    func saveCompletionValue() {
        self.completed = true
        UserDefaults.standard.set(true, forKey: onboardingStatusKey)
    }
}

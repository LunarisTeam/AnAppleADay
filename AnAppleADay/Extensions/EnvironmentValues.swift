//
//  EnvironmentValues.swift
//  AnAppleADay
//
//  Created by Giuseppe Rocco on 28/04/25.
//

import SwiftUI

/// Extends the SwiftUI `EnvironmentValues` to include a `setMode` property.
///
/// This property provides access to a closure or function that changes the current mode of the application.
/// It enables SwiftUI views to retrieve or assign this functionality using the environment, allowing for
/// decoupled and reusable mode-switching logic across the UI hierarchy.
extension EnvironmentValues {
    
    /// A function stored in the environment used to set the current mode.
    ///
    /// The function is defined by the `SetModeKey` and injected via the environment.
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}

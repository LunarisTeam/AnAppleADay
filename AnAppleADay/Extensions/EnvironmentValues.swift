//
//  EnvironmentValues.swift
//  AnAppleADay
//
//  Created by Giuseppe Rocco on 28/04/25.
//

import SwiftUI

/// Extends the SwiftUI EnvironmentValues to include a `setMode` property.
///
/// This allows any SwiftUI view to access or assign a mode-changing function via the environment.
extension EnvironmentValues {
    
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}

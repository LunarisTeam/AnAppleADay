//
//  SetModeKey.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

import SwiftUI

/// An environment key used to handle mode changes within the application.
///
/// `SetModeKey` provides a way to inject a mode-changing function into the SwiftUI
/// environment. The function takes a `Mode` and an optional `DicomDataSet`, and performs
/// asynchronous operations to update the application's state.
///
/// This is especially useful for coordinating navigation or app state transitions from
/// deep within the SwiftUI view hierarchy.
///
/// The default value is a no-op closure. It's marked as `nonisolated(unsafe)` because it's
/// expected to be called from the `MainActor`, and concurrency safety is enforced by usage
/// patterns rather than the compiler (for now). This prepares for stricter concurrency
/// enforcement in Swift 6.
struct SetModeKey: EnvironmentKey {
    
    /// A no-op default implementation. Expected to be overridden in an environment context.
    nonisolated(unsafe) static let defaultValue: Value = { _, _ in }
    
    /// The function type that updates the mode. It accepts a `Mode` and an optional `DicomDataSet`,
    /// and runs asynchronously.
    typealias Value = (Mode, DicomDataSet?) async -> Void
}

/// Extends the SwiftUI EnvironmentValues to include a `setMode` property.
///
/// This allows any SwiftUI view to access or assign a mode-changing function via the environment.
extension EnvironmentValues {
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}

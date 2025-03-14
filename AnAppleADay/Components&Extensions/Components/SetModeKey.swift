//
//  SetModeKey.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

import SwiftUI

/// An environment key for handling mode changes within the application.
///
/// `SetModeKey` defines a function type that accepts a `Mode` and performs asynchronous operations
/// to update the application's state. This key extends the SwiftUI environment, allowing views to
/// trigger mode transitions by calling the provided function.
///
/// The default value is a no-operation closure marked as `nonisolated(unsafe)` since its proper use
/// is ensured by invoking it on the `MainActor`. The setup anticipates a possible migration to Swift 6 strict concurrency.
struct SetModeKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: Value = { _, _ in }
    typealias Value = (Mode, URL? ) async -> Void
}

extension EnvironmentValues {
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}

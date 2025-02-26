//
//  SetModeKey.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

import SwiftUI

/// A struct used to extend `@Environment`.
/// Defualt value can be `nonisolated(unsafe)` since it's protected in `setMode` through the `MainActor`
/// This is also ready for eventual switch to`Swift6`
struct SetModeKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: Value = { _ in }
    typealias Value = (Mode) async -> Void
}

extension EnvironmentValues {
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}

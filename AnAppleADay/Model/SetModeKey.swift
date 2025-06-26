// Copyright 2025 Lunaris Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ---------------------------------------------------------------------------
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

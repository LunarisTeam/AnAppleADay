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

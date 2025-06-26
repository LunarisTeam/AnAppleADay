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
//  View.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 27/02/25.
//

import SwiftUI

extension View {
    
    /// Conditionally transforms the view.
    ///
    /// If the condition is `false`, the view remains unchanged.
    ///
    /// This function is very useful for normal 2D views. However, use carefully on `RealityView`.
    /// The way `@ViewBuilder` functions work, is because they rebuild the view everytime.
    ///
    /// ### Example Usage:
    /// ```
    /// someView.if(showDoneButton) { view in
    ///     view.overlay(alignment: .bottom) {
    ///         Button {
    ///             counter += 1
    ///         } label: {
    ///             Text("Ok!")
    ///         }
    ///         .buttonStyle(.bordered)
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///   - condition: The condition that must be met for the transformation to be applied.
    ///   - transform: A closure that takes the current view as input and returns a modified view.
    /// - Returns: The transformed view if `condition` is `true`, the original otherwise.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

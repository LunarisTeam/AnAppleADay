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
//  VisionOSButtonStyle.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 02/04/25.
//

import SwiftUI

/// A custom `ButtonStyle` designed for visionOS buttons, supporting multiple visual states.
///
/// This style adjusts the button's appearance based on its interaction state:
/// - Selected: Appears solid white.
/// - Pressed: Shows a blue outline and slightly shrinks.
/// - Disabled: Reduces opacity to indicate inactivity.
///
/// This style helps ensure consistency with the visionOS UI aesthetic.
struct VisionOSButtonStyle: ButtonStyle {

    /// Indicates whether the button is in a selected (toggled-on) state.
    var isSelected: Bool = false

    /// Environment property that reflects whether the button is enabled.
    @Environment(\.isEnabled) private var isEnabled

    /// Creates the visual representation of the button.
    ///
    /// - Parameter configuration: The current configuration of the button, including its label and pressed state.
    /// - Returns: A view that reflects the current button state.
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(
                // Use solid white background when selected or pressed.
                Circle().fill(
                    (isSelected || configuration.isPressed)
                        ? Color.white
                        : Color.background.opacity(0.5)
                )
            )
            .overlay(
                // Apply a blue stroke border when pressed.
                Circle().stroke(
                    configuration.isPressed ? Color.blue : Color.clear,
                    lineWidth: 1
                )
            )
            // Dim the button if it is disabled.
            .opacity(isEnabled ? 1.0 : 0.4)
            // Apply a shrink animation while pressed.
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .hoverEffect(.highlight)
    }
}

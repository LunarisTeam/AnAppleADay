//
//  VisionOSButtonStyle.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 02/04/25.
//

import SwiftUI

/// Custom ButtonStyle for visionOS buttons,
/// handling different states (idle, pressed, selected, disabled)
struct VisionOSButtonStyle: ButtonStyle {
    // Indicates if the button is in a toggled/selected state.
    var isSelected: Bool = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(
                // If the button is selected or pressed, the background remains white,
                 // otherwise the background color with reduced opacity is applied.
                Circle().fill(
                    (isSelected || configuration.isPressed)
                    ? Color.white
                    : Color.background.opacity(0.5)
                )
            )
            .overlay(
                // Shows a blue border when the button is pressed.
                Circle().stroke(
                    configuration.isPressed ? Color.blue : Color.clear,
                    lineWidth: 1
                )
            )
            // Reduces opacity if the button is disabled.
            .opacity(isEnabled ? 1.0 : 0.4)
            // Slight shrink effect when button is pressed for visual feedback.
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .hoverEffect(.highlight)
    }
}

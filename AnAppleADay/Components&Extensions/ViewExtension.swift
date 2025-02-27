//
//  ViewExtension.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 27/02/25.
//

import SwiftUI

extension View {
    
    /// Conditionally transforms the view.
    ///
    /// Use this method to apply a transformation to the view only if the specified condition is true.
    /// If the condition is false, the original view is returned unchanged.
    ///
    /// ### Example Usage:
    /// ```swift
    /// someView.conditionalModifier(showDoneButton) { view in
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
    ///   - condition: A Boolean value that determines whether the transformation should be applied.
    ///   - transform: A closure that transforms the view content when the condition is `true`.
    /// - Returns: A modified view if the condition is met; otherwise, the original view.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

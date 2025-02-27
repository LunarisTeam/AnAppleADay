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

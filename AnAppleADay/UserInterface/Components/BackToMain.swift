//
//  BackToMain.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 01/04/25.
//

import SwiftUI

/// A button view that prompts the user to return to the main screen of the application.
///
/// When tapped, an alert appears asking for confirmation. If the user confirms,
/// the app switches back to the `.importDicoms` mode using the injected `setMode` environment value.
///
/// This view is styled as a circular back button with a chevron icon.
struct BackToMain: View {
    
    /// The environment value used to change the application's current mode.
    @Environment(\.setMode) private var setMode

    /// A flag that determines whether the confirmation alert is presented.
    @State private var showAlert: Bool = false

    var body: some View {
        Button {
            showAlert = true
        } label: {
            Image(systemName: "chevron.left")
        }
        .buttonBorderShape(.circle)
        .background(Circle().fill(.background.opacity(0.3)))
        .help("Back")
        .alert("Return to main screen", isPresented: $showAlert) {
            Button("Confirm", role: .destructive) {
                Task { await setMode(.importDicoms, nil) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action is irreversible.")
                .fontWeight(.regular)
        }
    }
}

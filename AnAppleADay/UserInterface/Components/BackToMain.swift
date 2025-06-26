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

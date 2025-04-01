//
//  BackToMain.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 01/04/25.
//

import SwiftUI

struct BackToMain: View {
    
    @Environment(\.setMode) private var setMode
    
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
            VStack {
                Text("This action is irreversible.")
                    .fontWeight(.regular)
            }
        }
    }
}

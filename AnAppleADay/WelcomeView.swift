//
//  ContentView.swift
//  AnAppleADay
//
//  Created by Eduardo Gonzalez Melgoza on 25/02/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct WelcomeView: View {
        
    @Environment(\.setMode) private var setMode

    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.title2)
            Button {
                Task { await setMode(.importDicoms) }
            } label: {
                Text("go import")
            }
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    WelcomeView()
}

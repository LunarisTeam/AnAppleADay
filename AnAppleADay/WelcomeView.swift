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
    
    @EnvironmentObject private var mode: EnvironmentMode
    
    var body: some View {
        VStack {
            Text("Welcome!")
            
            Button {
                Task { await mode.setMode(.importDicoms) }
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

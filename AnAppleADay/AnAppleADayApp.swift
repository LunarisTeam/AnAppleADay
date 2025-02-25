//
//  AnAppleADayApp.swift
//  AnAppleADay
//
//  Created by Eduardo Gonzalez Melgoza on 25/02/25.
//

import SwiftUI

@main
struct AnAppleADayApp: App {
    
    @StateObject private var mode = EnvironmentMode(
        dismissWindow: { id in print("Dismissing window: \(id)")},
        openWindow: { id in print("Opening window: \(id)") },
        openImmersiveSpace: { id in print("Opening immersive space") },
        dismissImmersiveSpace: { print("Dismissing immersive space") }
    )
    
    fileprivate var modeID: String {
        return mode.mode.windowId
    }
        
    var body: some Scene {
        
        WindowGroup(id: modeID) {
            WelcomeView()
                .environmentObject(mode)
        }
        
        WindowGroup(id: modeID) {
            ImportDicomViews()
                .environmentObject(mode)
        }
    }
}

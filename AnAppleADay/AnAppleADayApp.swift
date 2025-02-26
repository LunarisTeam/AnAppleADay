//
//  AnAppleADayApp.swift
//  AnAppleADay
//
//  Created by Eduardo Gonzalez Melgoza on 25/02/25.
//

import SwiftUI

@main
struct AnAppleADayApp: App {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var mode: Mode = .importDicoms
    
    var body: some Scene {
        
        WindowGroup(id: WindowIDs.importDicomsWindowID) {
            ImportDicomViews()
                .environment(\.setMode, setMode)
        }
        .defaultSize(.init(width: 0.3, height: 0.2), in: .meters)
    }
    
    /// A helper function that handles the state changes of the app.
    ///
    /// The function will populated as needed in the future versions.
    /// it is `imperative` to put the task to sleep whenever there is a context switch.
    ///
    /// Call this function whenever you want to open a new window.
    /// However, first define an id in `WindowIDs`, then the associated case in `ModeEnum`
    ///
    /// - Parameter newMode: is the next mode after interacting within the app
    @MainActor private func setMode(_ newMode: Mode) async {
        
        let oldMode = mode
        guard newMode != oldMode else { return }
        mode = newMode
        
        openWindow(id: newMode.windowId)
        try? await Task.sleep(for: .seconds(0.01))
        dismissWindow(id: oldMode.windowId)
    }
}




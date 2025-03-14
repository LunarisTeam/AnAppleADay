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
    
    /// Represents the current operational mode of the application.
    ///
    /// The mode determines which view is presented and which window is active. Its initial value
    /// is set to `.importDicoms`.
    @State private var mode: Mode = .importDicoms
    
    var body: some Scene {
        
        Group {
            WindowGroup(id: WindowIDs.importDicomsWindowID) {
                ZStack {
                    Color("backgroundColor")
                        .opacity(0.3)
                    ImportDicomView()
                }
                
            }
            
            WindowGroup(id: WindowIDs.generateModelWindowID, for: URL?.self) { url in
                
                if let firstUnwrap = url.wrappedValue, let secondUnwrap = firstUnwrap {
                    ZStack {
                        Color("backgroundColor")
                            .opacity(0.3)
                        GenerateModelView(directoryURL: secondUnwrap)
                        
                    }
                }
                
                
            }
            
            WindowGroup(id: WindowIDs.model3DVolumeWindowID, for: URL?.self) { url in
                
                if let firstUnwrap = url.wrappedValue, let secondUnwrap = firstUnwrap {
                    ModelView(directoryURL: secondUnwrap)
                }
                
                
            }.windowStyle(.volumetric)
            
        }
        .environment(\.setMode, setMode)
    }
    
    /// Manages transitions between application modes by orchestrating the opening and dismissal of windows and immersive spaces.
    ///
    /// Each transition incorporates a brief pause to mitigate potential race conditions and concurrency issues on visionOS.
    /// The function must therefore adhere to the following guidelines:
    /// ```
    /// When opening a new window, follow this sequence:
    /// 1. Open the window.
    /// 2. Pause briefly to mitigate race conditions.
    /// 3. Optionally, dismiss any window if necessary.
    ///
    /// When opening an immersive space, use the same sequence:
    /// 1. Open the immersive space.
    /// 2. Pause briefly.
    /// 3. Optionally, dismiss the previously active immersive space.
    ///
    /// Whenever an immersive space must be closed, the flow can be whatever (as per date).
    /// ```
    /// - Parameter newMode: The new mode to transition to.
    @MainActor private func setMode(_ newMode: Mode, url: URL?) async {
        let oldMode = mode
        guard newMode != oldMode else { return }
        mode = newMode
        
        print("")
        print("oldMode: \(oldMode), newMode: \(newMode)")
        
        if newMode.acceptsURL{
            openWindow(id: newMode.windowId, value: url)
        }else{
            openWindow(id: newMode.windowId)
        }
        
        
        
        //The do-catch is to avoid skipping the await for concurrency issues.
        //Increase the sleep if it doesn't work.
        
        try? await Task.sleep(for: .seconds(0.05))
        
        if oldMode.acceptsURL{
            dismissWindow(id: oldMode.windowId, value: url)
        }else{
            dismissWindow(id: oldMode.windowId)
        }
    }
}




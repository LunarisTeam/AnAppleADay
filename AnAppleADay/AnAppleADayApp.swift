//
//  AnAppleADayApp.swift
//  AnAppleADay
//
//  Created by Eduardo Gonzalez Melgoza on 25/02/25.
//

import SwiftUI
import RealityKitContent

@main
struct AnAppleADayApp: App {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var appModel: AppModel = .init()
    @State private var appModelServer: AppModelServer = .init()
    
    /// Represents the current operational mode of the application.
    ///
    /// The mode determines which view is presented and which window is active. Its initial value
    /// is set to `.importDicoms`.
    @State private var mode: Mode = .importDicoms
    @State private var immersiveSpacePresented: Bool = false
    
    @State private var onboarding: OnboardingParameters = .init()
    
    init() {
        RealityKitContent.ObjComponent.registerComponent()
        // Register custom RealityKit components once
    }
    
    var body: some Scene {
        
        Group {
            /// This will be adjusted in the design area, therefore I will leave it like this
            WindowGroup(id: WindowIDs.importDicomsWindowID) {
                ZStack {
                    Color("backgroundColor")
                        .opacity(0.3)
                    if onboarding.completed {
                        ImportDicomView()
                    } else {
                        InfoView(showInfo: .constant(true))
                    }
                }
#if DEBUG
                .if(onboarding.completed) {
                    $0.overlay(alignment: .bottomLeading) {
                        Button("Erase Cache", systemImage: "trash") {
                            let contents = try? FileManager.default.contentsOfDirectory(
                                at: DicomDataSet.cacheDirectory,
                                includingPropertiesForKeys: nil,
                                options: []
                            )
                            
                            for item in contents ?? [] {
                                print("✅ Erasing \(item.lastPathComponent) from cache")
                                try? FileManager.default.removeItem(at: item)
                            }
                        }.padding(32)
                    }
                }
#endif
            }
            .defaultSize(width: 0.4971, height: 0.4044, depth: 0, in: .meters)
            .environment(onboarding)
            
            WindowGroup(id: WindowIDs.xRayFeedWindowID) {
                VideoPlayerView()
                    .onDisappear {
                        print("disppear from window group")
                        Task { await setMode(.immersiveSpace, dataSet: nil) }
                    }
                    .environment(appModel)
                    .environment(appModelServer)
            }
            .windowResizability(.contentSize)
            .windowStyle(.plain)
            .defaultSize(width: 0.4971, height: 0.4044, depth: 0, in: .meters)
            
            WindowGroup(id: WindowIDs.generateModelWindowID, for: DicomDataSet?.self) { dataSet in
                
                if let firstUnwrap = dataSet.wrappedValue,
                   let secondUnwrap = firstUnwrap {
                    
                    ZStack {
                        Color("backgroundColor")
                            .opacity(0.3)
                        GenerateModelView(dataSet: secondUnwrap)
                            .environment(appModel)
                            .fixedSize()
                    }
                    
                }
            }
            
            .windowResizability(.contentSize)
            .defaultSize(width: 0.4971, height: 0.4044, depth: 0, in: .meters)
            
            WindowGroup(id: WindowIDs.inputAddressWindowID) {
                InputAddressView()
                    .environment(appModel)
                    .environment(appModelServer)
            }
            .windowResizability(.contentSize)
            .windowStyle(.plain)
            .defaultSize(width: 0.3500, height: 0.3500, depth: 0, in: .meters)
            
            WindowGroup(id: WindowIDs.progressWindowID, for: DicomDataSet?.self) { dataSet in
                
                if let firstUnwrap = dataSet.wrappedValue,
                   let secondUnwrap = firstUnwrap {
                    ZStack {
                        Color("backgroundColor")
                            .opacity(0.3)
                        ProgressModelView(dataSet: secondUnwrap)
                            .environment(appModel)
                            .fixedSize()
                    }
                }
            }
            .defaultSize(width: 0.4971, height: 0.4044, depth: 0, in: .meters)
            
            WindowGroup(id: WindowIDs.controlPanelWindowID) {
                
                HStack {
                    BackToMain()
                    ControlPanel().environment(appModelServer)
                }
                .environment(appModel)
            }
            .windowStyle(.plain)
            .defaultSize(width: 0.4000, height: 0.0500, depth: 0, in: .meters)
            
            ImmersiveSpace(id: WindowIDs.immersiveSpaceID) {
                ModelView()
                    .environment(appModel)
            }
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
    ///
    ///
    /// From main screen (import dicoms) the user can either press popover or generate model. Popover is automatic so there is only one flow: generate the model
    /// The generate model needs the dataset.
    /// After selecting the files the user can either go back or generate the model, if he goes back it's back to the main view, otherwise it's progress view
    /// After the progress is completed, an immersive space is open, while overlapping a window group with 7 buttons.
    /// Only one of these buttons uses the setMode, to go back to the main screen.
    @MainActor private func setMode(_ newMode: Mode, dataSet: DicomDataSet?) async {
        let oldMode = mode
        guard newMode != oldMode else {
            print("setMode: newMode \(newMode) is the same as oldMode. No action taken.")
            return
        }
        
        print("Transitioning from \(oldMode) to \(newMode)")
        mode = newMode
        
        if immersiveSpacePresented && newMode == .importDicoms {
            
            dismissWindow(id: WindowIDs.controlPanelWindowID)
            await dismissImmersiveSpace()
            immersiveSpacePresented = false
        }
        
        if newMode.needsImmersiveSpace && !immersiveSpacePresented {

            immersiveSpacePresented = true
            await openImmersiveSpace(id: newMode.windowId)
            openWindow(id: WindowIDs.controlPanelWindowID)
            dismissWindow(id: oldMode.windowId)
        }
        
        if newMode.acceptsDataSet {
            
            openWindow(id: newMode.windowId, value: dataSet)
            try? await Task.sleep(for: .seconds(0.25))
            if !oldMode.needsImmersiveSpace { dismissWindow(id: oldMode.windowId) }
            
        } else if immersiveSpacePresented && newMode.overlapsImmersiveSpace {
            
            openWindow(id: newMode.windowId)
            dismissWindow(id: WindowIDs.inputAddressWindowID)
            
        } else if !newMode.acceptsDataSet && !immersiveSpacePresented {
            
            openWindow(id: newMode.windowId)
            try? await Task.sleep(for: .seconds(0.25))
            if appModelServer.isConnected {
                dismissWindow(id: WindowIDs.xRayFeedWindowID)
                appModelServer.isConnected = false
            }
        }
    }
}
/**
 @MainActor private func setMode(_ newMode: Mode, dataSet: DicomDataSet?) async {
 let oldMode = mode
 guard newMode != oldMode else { return }
 mode = newMode
 
 print("")
 print("oldMode: \(oldMode), newMode: \(newMode)")
 
 if newMode == .needsImmersiveSpace {
 await openImmersiveSpace(id: newMode.windowId)
 dismissWindow(id: oldMode.windowId)
 
 } else {
 if newMode.acceptsDataSet {
 openWindow(id: newMode.windowId, value: dataSet)
 } else { openWindow(id: newMode.windowId) }
 }
 
 
 //The do-catch is to avoid skipping the await for concurrency issues.
 //Increase the sleep if it doesn't work.
 try? await Task.sleep(for: .seconds(0.05))
 
 if oldMode.acceptsDataSet {
 if oldMode.immersiveSpaceIsOpen {
 
 } else {
 dismissWindow(id: oldMode.windowId, value: dataSet)
 }
 } else {
 if oldMode.windowId == "ControlPanel" {
 
 } else {
 dismissWindow(id: oldMode.windowId)
 }
 }
 }
 **/




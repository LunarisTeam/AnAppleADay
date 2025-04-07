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
                    if onboarding.completed {
                        ImportDicomView()
                    } else {
                        InfoView(showInfo: .constant(true))
                    }
                }
                .frame(width: 676, height: 550)
                .fixedSize()
                .background(Color.background.opacity(0.3))
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
            .windowResizability(.contentSize)
            .environment(onboarding)
            
            WindowGroup(id: WindowIDs.xRayFeedWindowID) {
                VideoPlayerView()
                    .frame(width: 676, height: 550)
                    .fixedSize()
                    .background(Color.background.opacity(0.3))
                    .environment(appModel)
                    .environment(appModelServer)
            }
            .windowResizability(.contentSize)
            .windowStyle(.plain)
            
            WindowGroup(id: WindowIDs.generateModelWindowID, for: DicomDataSet?.self) { dataSet in
                
                if let firstUnwrap = dataSet.wrappedValue,
                   let secondUnwrap = firstUnwrap {
                    
                    GenerateModelView(dataSet: secondUnwrap)
                        .environment(appModel)
                        .frame(width: 676, height: 550)
                        .fixedSize()
                        .background(Color.background.opacity(0.3))
                }
            }
            .windowResizability(.contentSize)
            
            
            WindowGroup(id: WindowIDs.inputAddressWindowID) {
                InputAddressView()
                    .environment(appModel)
                    .environment(appModelServer)
                    .frame(width: 381, height: 449)
                    .fixedSize()
            }
            .windowResizability(.contentSize)
            .windowStyle(.plain)
            .defaultSize(width: 381, height: 449)
            
            WindowGroup(id: WindowIDs.progressWindowID, for: DicomDataSet?.self) { dataSet in
                
                if let firstUnwrap = dataSet.wrappedValue,
                   let secondUnwrap = firstUnwrap {
                    
                    ProgressModelView(dataSet: secondUnwrap)
                        .environment(appModel)
                        .frame(width: 676, height: 550)
                        .fixedSize()
                        .background(Color.background.opacity(0.3))
                }
            }
            .windowResizability(.contentSize)
            
            WindowGroup(id: WindowIDs.controlPanelWindowID) {
                
                HStack {
                    BackToMain()
                    ControlPanel().environment(appModelServer)
                        .background(Capsule().fill(.background.opacity(0.3)))
                }
                .frame(width: 550, height: 68)
                .fixedSize()
                .environment(appModel)
            }
            .defaultWindowPlacement{ _, _ in
                return WindowPlacement(.utilityPanel)
            }
            .windowStyle(.plain)
            .windowResizability(.contentSize)
            
            ImmersiveSpace(id: WindowIDs.immersiveSpaceID) {
                ModelView().environment(appModel)
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
    @MainActor private func setMode(_ newMode: Mode, dataSet: DicomDataSet?) async {
        let oldMode = mode
        guard newMode != oldMode else {
            print("setMode: newMode \(newMode) is the same as oldMode. No action taken.")
            return
        }
        
        print("Transitioning from \(oldMode) to \(newMode)")
        mode = newMode
        
        switch immersiveSpacePresented {
        case true:
            if newMode.overlapsImmersiveSpace { openWindow(id: newMode.windowId) }
            
            if newMode.shouldStopImmersion {
                
                if appModelServer.isConnected { dismissWindow(id: WindowIDs.xRayFeedWindowID) }
                dismissWindow(id: WindowIDs.controlPanelWindowID)
                await dismissImmersiveSpace()
                immersiveSpacePresented = false
                openWindow(id: newMode.windowId)
            }
            try? await Task.sleep(for: .seconds(0.2))
            
        case false:
            if newMode.needsImmersiveSpace {
                
                immersiveSpacePresented = true
                await openImmersiveSpace(id: newMode.windowId)

                openWindow(id: WindowIDs.controlPanelWindowID)
                dismissWindow(id: oldMode.windowId)
                
            } else {
                
                if newMode.acceptsDataSet { openWindow(id: newMode.windowId, value: dataSet) }
                else { openWindow(id: newMode.windowId) }
                
                try? await Task.sleep(for: .seconds(0.2))
                dismissWindow(id: oldMode.windowId)
            }
        }
    }
}

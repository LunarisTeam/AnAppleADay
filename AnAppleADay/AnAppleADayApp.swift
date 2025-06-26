//
//  AnAppleADayApp.swift
//  AnAppleADay
//
//  Created by Eduardo Gonzalez Melgoza on 25/02/25.
//

import SwiftUI
import RealityKitContent

/// The main entry point for the `AnAppleADay` application.
///
/// This struct manages all application-level state and scene definitions, including window groups,
/// immersive spaces, onboarding flow, and mode transitions. The app supports both 2D and immersive
/// experiences, with modes determining which views and scenes are active at any given time.
@main
struct AnAppleADayApp: App {

    // MARK: - Environment Values
    
    /// Opens a new SwiftUI window group by ID.
    @Environment(\.openWindow) private var openWindow

    /// Dismisses a SwiftUI window group by ID.
    @Environment(\.dismissWindow) private var dismissWindow

    /// Opens an immersive RealityKit scene by ID.
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    /// Dismisses the currently active immersive space.
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    // MARK: - App State

    /// The primary application model managing scene data and entity state.
    @State private var appModel: AppModel = .init()

    /// Represents the current active mode of the application.
    ///
    /// Determines which view is presented and which scene or window should be visible.
    @State private var mode: Mode = .importDicoms

    /// Indicates whether an immersive space is currently presented.
    @State private var immersiveSpacePresented: Bool = false

    /// Manages onboarding completion status.
    @State private var onboarding: OnboardingParameters = .init()

    // MARK: - Initializer

    /// Registers RealityKit custom components at app launch.
    init() {
        RealityKitContent.ObjComponent.registerComponent()
    }

    // MARK: - Scene Declaration

    var body: some Scene {
        Group {
            // MARK: Import DICOM View (Default Entry)
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

            // MARK: Generate Model View
            WindowGroup(id: WindowIDs.generateModelWindowID, for: DicomDataSet?.self) { dataSet in
                if let ds = dataSet.wrappedValue, let validDataSet = ds {
                    GenerateModelView(dataSet: validDataSet)
                        .environment(appModel)
                        .frame(width: 676, height: 550)
                        .fixedSize()
                        .background(Color.background.opacity(0.3))
                }
            }
            .windowResizability(.contentSize)

            // MARK: Input Address View
            WindowGroup(id: WindowIDs.inputAddressWindowID) {
                InputAddressView()
                    .environment(appModel)
                    .frame(width: 381, height: 449)
                    .fixedSize()
            }
            .windowResizability(.contentSize)
            .windowStyle(.plain)
            .defaultSize(width: 381, height: 449)

            // MARK: Progress View
            WindowGroup(id: WindowIDs.progressWindowID, for: DicomDataSet?.self) { dataSet in
                if let ds = dataSet.wrappedValue, let validDataSet = ds {
                    ProgressModelView(dataSet: validDataSet)
                        .environment(appModel)
                        .frame(width: 676, height: 550)
                        .fixedSize()
                        .background(Color.background.opacity(0.3))
                }
            }
            .windowResizability(.contentSize)

            // MARK: Control Panel
            WindowGroup(id: WindowIDs.controlPanelWindowID) {
                HStack {
                    BackToMain()
                    ControlPanel()
                        .background(Capsule().fill(.background.opacity(0.3)))
                }
                .frame(width: 550, height: 68)
                .fixedSize()
                .environment(appModel)
            }
            .defaultWindowPlacement { _, _ in WindowPlacement(.utilityPanel) }
            .windowStyle(.plain)
            .windowResizability(.contentSize)

            // MARK: Immersive Model View
            ImmersiveSpace(id: WindowIDs.immersiveSpaceID) {
                ModelView().environment(appModel)
            }
        }
        .environment(\.setMode, setMode)
    }

    // MARK: - Mode Transition Handler

    /// Manages transitions between application modes by orchestrating the opening and dismissal of windows and immersive spaces.
    ///
    /// This function is designed to mitigate race conditions and threading issues specific to visionOS by introducing brief delays.
    ///
    /// Usage pattern:
    /// - Open the window or immersive space for `newMode`
    /// - Pause briefly
    /// - Dismiss previous windows or immersive spaces if needed
    ///
    /// - Parameters:
    ///   - newMode: The new application mode to transition to.
    ///   - dataSet: An optional DICOM dataset to pass to the next view (used by `.generate` and `.progress` modes).
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
            if newMode.overlapsImmersiveSpace {
                openWindow(id: newMode.windowId)
            }

            if newMode.shouldStopImmersion {
                appModel.videoEntityHolder = nil
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
                if newMode.acceptsDataSet {
                    openWindow(id: newMode.windowId, value: dataSet)
                } else {
                    openWindow(id: newMode.windowId)
                }

                try? await Task.sleep(for: .seconds(0.2))
                dismissWindow(id: oldMode.windowId)
            }
        }
    }
}

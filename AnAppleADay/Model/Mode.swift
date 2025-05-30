//
//  Mode.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

/// Represents the current state or "mode" of the application.
///
/// Each mode corresponds to a specific feature or interface shown to the user,
/// such as importing DICOM files, generating 3D models, or working in an immersive space.
///
/// The enum conforms to `Equatable` and is annotated with `@MainActor`,
/// ensuring that all interactions with `Mode` occur on the main thread.
/// This is essential when updating state in a SwiftUI environment.
@MainActor enum Mode: Equatable {

    /// Mode for importing DICOM datasets.
    case importDicoms

    /// Mode for generating 3D models from DICOM data.
    case generate

    /// Mode for displaying the generated 3D volume in an immersive space.
    case immersiveSpace

    /// Mode for entering server address information.
    case inputAddress

    /// Mode for viewing the live fluoroscope feed.
    case xRayFeed

    /// Mode for displaying control panels within the immersive space.
    case controlPanel

    /// Mode for showing a loading or progress indicator.
    case progress

    /// A unique identifier for the window or scene associated with the current mode.
    ///
    /// Used to map a `Mode` to its corresponding `WindowGroup` or `ImmersiveSpace` identifier.
    var windowId: String {
        switch self {
        case .importDicoms: return WindowIDs.importDicomsWindowID
        case .generate: return WindowIDs.generateModelWindowID
        case .xRayFeed: return WindowIDs.xRayFeedWindowID
        case .immersiveSpace: return WindowIDs.immersiveSpaceID
        case .inputAddress: return WindowIDs.inputAddressWindowID
        case .controlPanel: return WindowIDs.controlPanelWindowID
        case .progress: return WindowIDs.progressWindowID
        }
    }

    /// Indicates whether the current mode is capable of accepting a `DicomDataSet`.
    ///
    /// This is useful for controlling navigation flow and data passing logic.
    var acceptsDataSet: Bool {
        switch self {
        case .generate, .progress:
            return true
        default:
            return false
        }
    }

    /// Indicates whether the current mode requires launching an immersive space.
    ///
    /// Used to trigger immersive session logic in the app lifecycle.
    var needsImmersiveSpace: Bool {
        return self == .immersiveSpace
    }

    /// Indicates whether transitioning to this mode should close the last opened window.
    ///
    /// Some modes (like `.immersiveSpace` and `.controlPanel`) can coexist with others.
    var needsLastWindowClosed: Bool {
        switch self {
        case .immersiveSpace, .controlPanel:
            return false
        default:
            return true
        }
    }

    /// Indicates whether the current mode overlays or shares space with the immersive space.
    ///
    /// Used to handle UI layering and window behavior when immersive content is active.
    var overlapsImmersiveSpace: Bool {
        return self == .xRayFeed
    }

    /// Indicates whether transitioning to this mode should terminate the current immersion session.
    ///
    /// For example, returning to `.importDicoms` stops immersive content.
    var shouldStopImmersion: Bool {
        return self == .importDicoms
    }
}

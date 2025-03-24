//
//  ModeEnum.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

/// Represents the current state or "mode" of the application.
///
/// Each mode corresponds to a specific user-facing feature or interface, such as
/// importing DICOM files, generating a model, or viewing a 3D volume.
///
/// The enum conforms to `Equatable` and is annotated with `@MainActor`,
/// meaning all interactions with `Mode` should occur on the main thread.
/// This ensures safe usage when switching modes in a SwiftUI environment.
@MainActor enum Mode: Equatable {
    
    /// The mode for importing DICOM datasets.
    case importDicoms
    
    /// The mode for generating 3D models from DICOM data.
    case generate
    
    /// The mode for displaying the generated 3D volume.
    case model3DVolume
    
    /// The identifier associated with the mode's corresponding window or scene.
    ///
    /// This value is used to reference the correct `WindowGroup` or `ImmersiveSpace`
    /// based on the active mode.
    var windowId: String {
        switch self {
        case .importDicoms: return WindowIDs.importDicomsWindowID
        case .generate: return WindowIDs.generateModelWindowID
        case .model3DVolume: return WindowIDs.model3DVolumeWindowID
        }
    }
    
    /// Indicates whether the mode supports receiving a `DicomDataSet`.
    ///
    /// Use this flag to determine if transitioning to a given mode should include
    /// a dataset (e.g., during navigation or processing steps).
    var acceptsDataSet: Bool {
        switch self {
        case .importDicoms: return false
        case .generate: return true
        case .model3DVolume: return true
        }
    }
}

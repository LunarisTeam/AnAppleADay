//
//  Mode.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

/// This `Mode` defines the state in which the app can be. Declare a case that returns a string.
/// Therefore, the associated WindowGroup/Immersive space will be called.
@MainActor enum Mode: Equatable {
    case importDicoms
    case generate
    case model3DVolume
    
    var windowId: String {
        switch self {
        case .importDicoms: return WindowIDs.importDicomsWindowID
        case .generate: return WindowIDs.generateModelWindowID
        case .model3DVolume: return WindowIDs.model3DVolumeWindowID
        }
    }
    
    var acceptsDataSet: Bool {
        switch self {
        case .importDicoms: return false
        case .generate: return true
        case .model3DVolume: return true
        }
    }
    
}

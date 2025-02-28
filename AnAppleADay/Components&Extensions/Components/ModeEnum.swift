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
    
    var windowId: String {
        switch self {
        case .importDicoms: return WindowIDs.importDicomsWindowID
        case .generate: return WindowIDs.generateModelWindowID
        }
    }
}

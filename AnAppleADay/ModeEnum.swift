//
//  Mode.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

/// This `Mode` defines the state in which the app can be.
/// It is imperative to declare a case that returns a string.
/// Therefore, the associated WindowGroup will be called
@MainActor enum Mode: Equatable {
    case welcome
    case importDicoms
    
    var windowId: String {
        switch self {
        case .welcome: return WindowIDs.welcomeWindowID
        case .importDicoms: return WindowIDs.importDicomsWindowID
        }
    }
}

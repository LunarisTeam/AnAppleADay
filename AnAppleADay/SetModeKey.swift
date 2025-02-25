//
//  SetModeKey.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

import SwiftUI

final class EnvironmentMode: ObservableObject {

    @Published var mode: Mode = .mainScreen
    @Published var immersiveSpacePresented: Bool = false

    @MainActor enum Mode: Equatable {
        case mainScreen
        case importDicoms

        fileprivate var needsImmersiveSpace: Bool {
            return self != .mainScreen
        }

        fileprivate var needsLastWindowClosed: Bool {
            return self == .mainScreen
        }

        var windowId: String {
            switch self {
            case .mainScreen: return mainWindowID
            case .importDicoms: return importDictionaryWindowID
            }
        }
    }
    
    static private let mainWindowID = "Main"
    static private let importDictionaryWindowID = "ImportingDicoms"
    
    private let dismissWindow: @MainActor (String) -> Void
    private let openWindow: @MainActor (String) -> Void
    private let openImmersiveSpace: @MainActor (String) async -> Void
    private let dismissImmersiveSpace: @MainActor () async -> Void

    init(
        dismissWindow: @escaping @MainActor (String) -> Void = { _ in },
        openWindow: @escaping @MainActor (String) -> Void = { _ in },
        openImmersiveSpace: @escaping @MainActor (String) async -> Void = { _ in },
        dismissImmersiveSpace: @escaping @MainActor () async -> Void = {}
    ) {
        self.dismissWindow = dismissWindow
        self.openWindow = openWindow
        self.openImmersiveSpace = openImmersiveSpace
        self.dismissImmersiveSpace = dismissImmersiveSpace
    }

    @MainActor func setMode(_ newMode: Mode) async {
        let oldMode = mode
        guard newMode != oldMode else { return }
        mode = newMode

        if immersiveSpacePresented {
            immersiveSpacePresented = false
            await dismissImmersiveSpace()
            openWindow(newMode.windowId)
        } else if newMode.needsLastWindowClosed {
            dismissWindow(oldMode.windowId)
            openWindow(newMode.windowId)
        }

        if newMode.needsImmersiveSpace {
            immersiveSpacePresented = true
            await openImmersiveSpace(newMode.windowId)
            dismissWindow(oldMode.windowId)
        }
    }
}

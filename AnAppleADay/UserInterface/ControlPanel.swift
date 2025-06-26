// Copyright 2025 Lunaris Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ---------------------------------------------------------------------------
//
//  ControlPanel.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 27/03/25.
//

import Foundation
import SwiftUI
import RealityKit

/// A floating control panel view providing UI buttons for manipulating the 3D and 2D surgical environment.
///
/// This view allows the user to toggle bounding boxes, reset model positions, enable or disable gesture interaction,
/// connect to a 2D X-ray feed, lock the X-ray display, and link the 2D/3D entities together.
/// It is intended to be displayed in an immersive space as a persistent overlay.
struct ControlPanel: View {
    
    /// Access to the main application model, injected from the environment.
    @Environment(AppModel.self) private var appModel
    
    /// Function to change the current application mode.
    @Environment(\.setMode) private var setMode
    
    /// Function to programmatically open new SwiftUI windows.
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack {
            // Semi-transparent background for panel visibility
            Color.background.opacity(0.3)
            
            HStack(spacing: 20) {

                // MARK: Show bounding box
                Button {
                    appModel.toggleBoundingBox()
                } label: {
                    Image("BoundingBox")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(appModel.mustShowBox ? Color.background : Color.white)
                        .frame(width: 36, height: 36)
                }
                .help("Show bounds")
                .buttonStyle(VisionOSButtonStyle(isSelected: appModel.mustShowBox))
                .frame(width: 36, height: 36)
                .padding(.trailing)

                // MARK: Reset position
                Button {
                    appModel.mustResetPosition = true
                } label: {
                    Image("FieldOfView")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.white)
                        .frame(width: 36, height: 36)
                }
                .help("Reset Position")
                .buttonStyle(VisionOSButtonStyle())
                .frame(width: 36, height: 36)

                // MARK: Toggle 3D gestures ("Lock")
                Button {
                    appModel.enableBonesGestures.toggle()
                } label: {
                    Image("lockInPosition")
                        .renderingMode(.template)
                        .foregroundStyle(!appModel.enableBonesGestures ? Color.background : Color.white)
                }
                .help("Lock position")
                .buttonStyle(VisionOSButtonStyle(isSelected: !appModel.enableBonesGestures))
                .disabled(appModel.entitiesLockedTogether)

                // MARK: Divider between groups
                Divider()
                    .frame(width: 10, height: 50)
                    .foregroundStyle(Color.gray)
                    .bold()

                // MARK: 2D Connection ("Connect")
                Button {
                    if appModel.videoEntityHolder != nil {
                        appModel.videoEntityHolder = nil
                    } else if !appModel.isInputWindowOpen {
                        openWindow(id: WindowIDs.inputAddressWindowID)
                    }
                } label: {
                    Image("connect2D")
                        .renderingMode(.template)
                        .foregroundStyle(appModel.videoEntityHolder != nil ? Color.background : Color.white)
                }
                .help("Connect window")
                .buttonStyle(VisionOSButtonStyle(isSelected: appModel.videoEntityHolder != nil))

                // MARK: Toggle X-Ray Lock ("Lock2D")
                Button {
                    Task(priority: .userInitiated) { @MainActor in
                        try? await appModel.videoEntityHolder?.toggleLockState()
                    }
                } label: {
                    Image("lock2d")
                        .renderingMode(.template)
                        .foregroundStyle(appModel.videoEntityHolder?.isLocked ?? false ? Color.background : Color.white)
                }
                .help("Lock Window")
                .buttonStyle(VisionOSButtonStyle(isSelected: appModel.videoEntityHolder?.isLocked ?? false))
                .disabled(appModel.videoEntityHolder == nil)

                // MARK: Lock model to window ("Lock2Dto3D")
                Button {
                    appModel.entitiesLockedTogether.toggle()
                } label: {
                    Image("LOCKINTO3D2")
                        .renderingMode(.template)
                        .foregroundStyle(appModel.entitiesLockedTogether ? Color.background : Color.white)
                }
                .help("Lock to Model")
                .buttonStyle(VisionOSButtonStyle(isSelected: appModel.entitiesLockedTogether))
                .disabled(appModel.videoEntityHolder == nil || !appModel.enableBonesGestures)
            }
            .buttonBorderShape(.circle)
        }
        .frame(height: 80)
        .glassBackgroundEffect()
        .persistentSystemOverlays(.visible)
    }
}

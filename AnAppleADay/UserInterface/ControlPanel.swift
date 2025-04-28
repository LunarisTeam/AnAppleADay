//
//  ControlPanel.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 27/03/25.
//

import Foundation
import SwiftUI
import RealityKit

struct ControlPanel: View {
    
    @Environment(AppModel.self) private var appModel
    @Environment(\.setMode) private var setMode
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack {
            Color.background.opacity(0.3)
            
            HStack(spacing: 20) {

                // Show bounding box
                Button {
                    appModel.toggleBoundingBox()
                } label: {
                    Image("showBoundingBox")
                        .resizable()
                        .foregroundStyle(Color.white)
                        .frame(width: 36, height: 36)
                }
                .help("Show bounds")
                .buttonStyle(VisionOSButtonStyle())
                .frame(width: 36, height: 36)
                
                // Reset position
                Button {
                    appModel.mustResetPosition = true
                } label: {
                    Image("fieldOfView")
                        .resizable()
                        .foregroundStyle(Color.white)
                        .frame(width: 36, height: 36)
                }
                .help("Reset Position")
                .buttonStyle(VisionOSButtonStyle())
                .frame(width: 36, height: 36)
                
                // Toggle 3D gestures ("Lock")
                Button {
                    appModel.enableBonesGestures.toggle()
                } label: {
                    Image("lockInPosition")
                        .renderingMode(.template)
                        .foregroundStyle(!appModel.enableBonesGestures ? Color.background : Color.white)
                }
                .help("Lock position")
                .buttonStyle(VisionOSButtonStyle(isSelected: !appModel.enableBonesGestures))
                
                // Divider between button groups
                Divider()
                    .frame(width: 10, height: 50)
                    .foregroundStyle(Color.gray)
                    .bold()
                
                // 2D Connection ("Connect")
                Button {
                    if appModel.videoEntityHolder != nil {
                        appModel.videoEntityHolder = nil
                        
                    } else if !appModel.isInputWindowOpen {
                        openWindow(id: WindowIDs.inputAddressWindowID)
                    }
                    // The button does not handle a local toggle; its selected state depends on the connection.
                } label: {
                    Image("connect2D")
                        .renderingMode(.template)
                        .foregroundStyle(appModel.videoEntityHolder != nil ? Color.background : Color.white)
                }
                .help("Connect window")
                .buttonStyle(VisionOSButtonStyle(isSelected: appModel.videoEntityHolder != nil))
                
                // Toggle X-Ray ("Lock2D")
                Button {
                    appModel.enableVideoGestures.toggle()
                } label: {
                    Image("lock2d")
                        .renderingMode(.template)
                        .foregroundStyle(!appModel.enableVideoGestures ? Color.background : Color.white)
                }
                .help("Lock Window")
                .buttonStyle(VisionOSButtonStyle(isSelected: !appModel.enableVideoGestures))
                // Disables the button if there is no 2D connection.
                .disabled(appModel.videoEntityHolder == nil)
                
                // Lock model to window ("Lock2Dto3D")
                Button {
                    
                } label: {
                    Image("LOCKINTO3D2")
                        .renderingMode(.template)
                        .foregroundStyle(false ? Color.background : Color.white)
                }
                .help("Lock to Model")
                .buttonStyle(VisionOSButtonStyle(isSelected: false))
                // Disables the button if there is no 2D connection.
                .disabled(appModel.videoEntityHolder == nil)
            }
            .buttonBorderShape(.circle) // Standard circular border shape for buttons.
        }
        .frame(height: 80)
        .glassBackgroundEffect()
        .persistentSystemOverlays(.visible)
    }
}

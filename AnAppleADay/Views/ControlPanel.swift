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
    
    @Environment(AppModelServer.self) private var appModelServer
    @Environment(AppModel.self) private var appModel
    @Environment(\.setMode) private var setMode
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack {
            Color.background.opacity(0.3)
            
            HStack(spacing: 20) {
                
                Button {
                    appModel.mustResetPosition = true
                } label: {
                    Image(systemName: "camera.metering.center.weighted")
                        .renderingMode(.template)
                        .foregroundStyle(Color.white)
                }
                .help("Restore Size")
                .buttonStyle(VisionOSButtonStyle())
                
                // Toggle 3D gestures ("Lock")
                Button {
                    appModel.toggleGestures()
                } label: {
                    Image("lockInPosition")
                        .renderingMode(.template)
                        .foregroundStyle(appModel.enableGestures ? Color.white : Color.background)
                }
                .help("Lock position")
                .buttonStyle(VisionOSButtonStyle(isSelected: !appModel.enableGestures))
                
                // Divider between button groups
                Divider()
                    .frame(width: 10, height: 50)
                    .foregroundStyle(Color.gray)
                    .bold()
                
                // 2D Connection ("Connect")
                Button {
                    guard !appModelServer.isInputWindowOpen else { return }
                    openWindow(id: WindowIDs.inputAddressWindowID)
                    // The button does not handle a local toggle; its selected state depends on the connection.
                } label: {
                    Image("connect2D")
                        .renderingMode(.template)
                        .foregroundStyle(appModelServer.isConnected ? Color.background : Color.white)
                }
                .help("Connect window")
                .buttonStyle(VisionOSButtonStyle(isSelected: appModelServer.isConnected))
                
                // Toggle X-Ray ("Lock2D")
                Button {
                    appModel.hideBar.toggle()
                } label: {
                    Image("lock2d")
                        .renderingMode(.template)
                        .foregroundStyle(appModel.hideBar ? Color.background : Color.white)
                }
                .help("Lock Window")
                .buttonStyle(VisionOSButtonStyle(isSelected: appModel.hideBar))
                // Disables the button if there is no 2D connection.
                .disabled(!appModelServer.isConnected)
                
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
                .disabled(!appModelServer.isConnected)
            }
            .buttonBorderShape(.circle) // Standard circular border shape for buttons.
        }
        .frame(height: 80)
        .glassBackgroundEffect()
        .persistentSystemOverlays(.visible)
    }
}

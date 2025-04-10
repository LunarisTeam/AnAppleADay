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
    
    // State variables to track the toggle (selected) state for the buttons.
    @State private var isHideSelected: Bool = false      // For "Hide" (bones/arteries)
    @State private var isLock3DSelected: Bool = false      // For "Lock" (3D gestures)
    @State private var isLock2DSelected: Bool = false      // For "Lock2D" (X-Ray)
    @State private var isLock2Dto3DSelected: Bool = false    // For "Lock2Dto3D" (model lock)
    
    var body: some View {
        ZStack {
            Color.background.opacity(0.3)
            
            HStack(spacing: 20) {
                
                // Toggle bones/arteries visibility ("Hide")
                Button {
                    appModel.bonesArteriesToggle()
                    isHideSelected.toggle()
                } label: {
                    Image("hideBones")
                        .renderingMode(.template)
                        .foregroundStyle(isHideSelected ? Color.background : Color.white)
                }
                .help(isHideSelected ? "Show Bones" : "Hide Bones")
                .buttonStyle(VisionOSButtonStyle(isSelected: isHideSelected))
                
                // Scale entities button
//                Button {
//                    appModel.scaleEntities()
//                } label: {
//                    Image("RestoreSize")
//                        .renderingMode(.template)
//                        .foregroundStyle(Color.white)
//                }
//                .help("Restore Size")
//                .buttonStyle(VisionOSButtonStyle())
                
                // Reset model's position
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
                    isLock3DSelected.toggle()
                } label: {
                    Image("lockInPosition")
                        .renderingMode(.template)
                        .foregroundStyle(isLock3DSelected ? Color.background : Color.white)
                }
                .help("Lock position")
                .buttonStyle(VisionOSButtonStyle(isSelected: isLock3DSelected))
                
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
                    isLock2DSelected.toggle()
                } label: {
                    Image("lock2d")
                        .renderingMode(.template)
                        .foregroundStyle(isLock2DSelected ? Color.background : Color.white)
                }
                .help("Lock Window")
                .buttonStyle(VisionOSButtonStyle(isSelected: isLock2DSelected))
                // Disables the button if there is no 2D connection.
                .disabled(!appModelServer.isConnected)
                
                // Lock model to window ("Lock2Dto3D")
                Button {
                    appModel.lockTogether()
                    isLock2Dto3DSelected.toggle()
                } label: {
                    Image("LOCKINTO3D2")
                        .renderingMode(.template)
                        .foregroundStyle(isLock2Dto3DSelected ? Color.background : Color.white)
                }
                .help("Lock to Model")
                .buttonStyle(VisionOSButtonStyle(isSelected: isLock2Dto3DSelected))
                // Disables the button if there is no 2D connection.
                .disabled(!appModelServer.isConnected)
            }
            .buttonBorderShape(.circle) // Standard circular border shape for buttons.
        }
        .frame(height: 80)
        .glassBackgroundEffect()
        .persistentSystemOverlays(.visible)
        // Reset toggles when view appears.
        .onAppear {
            isHideSelected = false
            isLock3DSelected = false
            isLock2DSelected = false
            isLock2Dto3DSelected = false
        }
        // Monitor connection state changes.
        .onChange(of: appModelServer.isConnected) { oldValue, newValue in
            if !newValue {
                isLock2DSelected = false
                isLock2Dto3DSelected = false
            }
        }
    }
}

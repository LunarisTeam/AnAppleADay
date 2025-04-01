//
//  ControlPanel.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 27/03/25.
//

import Foundation
import SwiftUI
import RealityKit

// The bones are the first element of the parent entity, while the second is the arteries
struct ControlPanel: View {
    
    @Environment(AppModelServer.self) private var appModelServer
    @Environment(AppModel.self) private var appModel
    @Environment(\.setMode) private var setMode
    @Environment(\.openWindow) private var openWindow
    
    @FocusState private var isFocused: Bool
    
    private let tooltipArray = [
        "Show/Hide Bones",
        "Enlarge/Shrink",
        "Lock position",
        "Connect X-Ray",
        "Lock window",
        "Lock model to window"
    ]
        
    var body: some View {
        
        ZStack {
            
            Color.background.opacity(0.3)
            
            HStack(spacing: 20) {
                //toggle bones arteries
                Button {
                    appModel.bonesArteriesToggle()
                }
                label: {
                    Image("hideBones")
                }
                .background(Circle().fill(.background.opacity(0.3)))
                .help(tooltipArray[0])
                
                //scale
                Button {
                    appModel.scaleEntities()
                }
                label: {
                    Image("RestoreSize")
                }
                .background(Circle().fill(.background.opacity(0.3)))
                .help(tooltipArray[1])
                
                //lock 3D
                Button {
                    appModel.toggleGestures()
                }
                label: {
                    Image("lockInPosition")
                }
                .background(Circle().fill(.background.opacity(0.3)))
                .help(tooltipArray[2])
                
                //Divider
                Divider().frame(width: 5, height: 40)
                
                //Show 2D image
                Button {
                    guard !appModelServer.isInputWindowOpen else { return }
                    openWindow(id: WindowIDs.inputAddressWindowID)
                } label: {
                    Image("connect2D")
                }
                .background(Circle().fill(.background.opacity(0.3)))
                .help(tooltipArray[3])
                
                Button {
                    appModel.hideBar.toggle()
                }
                label: {
                    Image("lock2d")
                }
                .help(tooltipArray[4])
                
                .background(Circle().fill(.background.opacity(0.3)))
                //LOCKINTO3D2
                Button {
                    
                } label: {
                    Image("LOCKINTO3D2")
                }
                .background(Circle().fill(.background.opacity(0.3)))
                .help(tooltipArray[5])
            }
            .buttonBorderShape(.circle)
        }
        .frame(height: 80)
        .glassBackgroundEffect()
        .persistentSystemOverlays(.visible)
    }
}

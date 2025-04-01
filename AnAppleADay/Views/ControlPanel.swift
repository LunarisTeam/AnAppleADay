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
                //toggle bones arteries
                Button {
                    appModel.bonesArteriesToggle()
                }
                label: {
                    Image("hideBones")
                }
                .background(Circle().fill(.background.opacity(0.3)))
                .help("Show/Hide Bones")
                
                //scale
                Button {
                    appModel.scaleEntities()
                }
                label: {
                    Image("RestoreSize")
                }
                .background(Circle().fill(.background.opacity(0.3)))
                .help("Enlarge/Shrink")
                
                //lock 3D
                Button {
                    appModel.toggleGestures()
                }
                label: {
                    Image("lockInPosition")
                }
                .background(Circle().fill(.background.opacity(0.3)))
                .help("Lock position")
                
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
                .help("Lock window")
                
                Button {
                    appModel.hideBar.toggle()
                }
                label: {
                    Image("lock2d")
                }
                .help("Connect X-Ray")
                
                .background(Circle().fill(.background.opacity(0.3)))
                //LOCKINTO3D2
                Button {
                    appModel.lockTogether()
                }
                label: {
                    Image ("LOCKINTO3D2" )
                }
                .background(Circle().fill(.background.opacity(0.3)))
                .help("Lock model to window")
            }
            .buttonBorderShape(.circle)
        }
        .frame(height: 80)
        .glassBackgroundEffect()
        .persistentSystemOverlays(.visible)
        
    }
}

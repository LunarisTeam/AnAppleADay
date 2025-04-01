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
    
    var body: some View {
        
        
        ZStack {
            
            Color("backgroundColor").opacity(0.3)
            
            HStack{
                //toggle bones arteries
                Button { appModel.bonesArteriesToggle() }
                label: { Image("hideBones") }
                
                //scale
                Button { appModel.scaleEntities() }
                label: { Image("RestoreSize") }
                
                
                //lock 3D
                Button { appModel.toggleGestures() }
                label: { Image("lockInPosition") }
                
                //Divider
                Divider().frame(width: 5, height: 40)
                
                //Show 2D image
                Button {
                    guard !appModelServer.isInputWindowOpen else { return }
                    openWindow(id: WindowIDs.inputAddressWindowID)
                } label: {
                    Image("connect2D")
                }
                
                
                Button { appModel.hideBar.toggle() }
                label: { Image("lock2d") }
                
                //LOCKINTO3D2
                Button {
                    appModel.lockTogether.toggle()
                    toggleGestures (component: appModel.bonesEntityHolder!, isEnabled: !appModel.lockTogether)
                }
                label: {
                    Image ("LOCKINTO3D2" )
                }
                
            }
            .padding(.horizontal, 30)
        }
        .frame(height: 75)
        .glassBackgroundEffect()
        .persistentSystemOverlays(.visible)
        
    }
    
    
    func toggleGestures(component: Entity, isEnabled: Bool) {
        component.gestureComponent?.canDrag = isEnabled
        component.gestureComponent?.canRotate = isEnabled
        component.gestureComponent?.canScale = isEnabled
        component.gestureComponent?.pivotOnDrag = isEnabled
        component.gestureComponent?.preserveOrientationOnPivotDrag = isEnabled
        
    }
}

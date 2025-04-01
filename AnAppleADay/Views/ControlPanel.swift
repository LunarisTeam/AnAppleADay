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
    
    @State private var gestures: Bool = true
    
    var body: some View {
        
            HStack{
                //toggle bones arteries
                Button {
                    appModel.bonesArteriesToggle()
                } label: {
                    Image("hideBones")
                }
                
                //scale
                Button {
                    appModel.scale.toggle()
                    if(appModel.scale){
                        appModel.bonesEntityHolder!.scale *= 2.0
                        appModel.arteriesEntityHolder!.scale *= 2.0
                    }else{
                        appModel.bonesEntityHolder!.scale /= 2.0
                        appModel.arteriesEntityHolder!.scale /= 2.0
                    }
                } label: {
                    Image("RestoreSize")
                }
                
                
                //lock 3D
                Button {
                    gestures.toggle()
                    toggleGestures(component: appModel.bonesEntityHolder!, isEnabled: gestures)
                    toggleGestures(component: appModel.arteriesEntityHolder!, isEnabled: gestures)
                } label: {
                    Image("lockInPosition")
                }
                
                //Divider
                Divider().frame(width: 5, height: 40)
                
                //Show 2D image
                Button {
                    //potentially show and hide the model so they don't overlap
                    Task { await setMode(.inputAddress, nil) }
                } label: {
                    Image("connect2D")
                }
                
                //lock 2D image
                Button {
                    appModelServer.hideBar.toggle()
                } label: {
                    Image("lock2d")
                }
                
                //LOCKINTO3D2
                Button {
                    
                } label: {
                    Image("LOCKINTO3D2")
                }
                
                
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
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

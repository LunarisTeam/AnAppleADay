//
//  ControlPanel.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 27/03/25.
//

import Foundation
import SwiftUI
import RealityKit

struct controlPanel: View {
    
    @State private var gestures: Bool = true
    @Environment(\.setMode) private var setMode
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        
        if appModel.bonesEntity != nil, appModel.arteriesEntity != nil{
            HStack{
                //toggle bones arteries
                Button {
                    appModel.bonesEntity!.isEnabled.toggle()
                    appModel.arteriesEntity!.isEnabled.toggle()
                    
                    if(!appModel.bonesEntity!.isEnabled){
                        appModel.arteriesEntity!.position = appModel.bonesEntity!.position
                        appModel.arteriesEntity!.scale = appModel.bonesEntity!.scale
                        appModel.arteriesEntity!.transform.rotation = appModel.bonesEntity!.transform.rotation
                    }else{
                        appModel.bonesEntity!.position = appModel.arteriesEntity!.position
                        appModel.bonesEntity!.scale = appModel.arteriesEntity!.scale
                        appModel.bonesEntity!.transform.rotation = appModel.arteriesEntity!.transform.rotation
                    }
                } label: {
                    Image("hideBones")
                }
                
                //scale
                Button {
                    appModel.scale.toggle()
                    if(appModel.scale){
                        appModel.bonesEntity!.scale *= 2.0
                        appModel.arteriesEntity!.scale *= 2.0
                    }else{
                        appModel.bonesEntity!.scale /= 2.0
                        appModel.arteriesEntity!.scale /= 2.0
                    }
                } label: {
                    Image("RestoreSize")
                }
                
                //lock 3D
                Button {
                    gestures.toggle()
                    toggleGestures(component:appModel.bonesEntity!, isEnabled: gestures)
                    toggleGestures(component: appModel.arteriesEntity!, isEnabled: gestures)
                } label: {
                    Image("lockInPosition")
                }
                
                //Divider
                Divider().frame(width: 5, height: 40)
                
                //Show 2D image
                Button {
                    //potentially show and hide the model so they don't overlap
                    Task{
                        await setMode(.inputAddress, nil)
                    }
                } label: {
                    Image("connect2D")
                }
                
                //lock 2D image
                Button {
                    appModel.hideBar.toggle()
                } label: {
                    Image("lock2d")
                }
                
                //LOCKINTO3D2
                Button {
                
                    
                    
                } label: {
                    Image("LOCKINTO3D2")
                }
            }.padding(.vertical, 20)
                .padding(.horizontal, 30)
            .glassBackgroundEffect()
            .persistentSystemOverlays(.visible)
            
        }

    }
    
    func toggleGestures(component: Entity, isEnabled: Bool) {
        component.gestureComponent?.canDrag = isEnabled
        component.gestureComponent?.canRotate = isEnabled
        component.gestureComponent?.canScale = isEnabled
        component.gestureComponent?.pivotOnDrag = isEnabled
        component.gestureComponent?.preserveOrientationOnPivotDrag = isEnabled
    }
}

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
    
    var bonesEntity: Entity
    var arteriesEntity: Entity
    @Binding var scale: Bool
    @State private var gestures: Bool = true
    @Environment(\.setMode) private var setMode
    
    let dataSet: DicomDataSet
    
    var body: some View {
        
        HStack{
            //toggle bones arteries
            Button {
                bonesEntity.isEnabled.toggle()
                arteriesEntity.isEnabled.toggle()
                
                if(!bonesEntity.isEnabled){
                    arteriesEntity.position = bonesEntity.position
                    arteriesEntity.scale = bonesEntity.scale
                    arteriesEntity.transform.rotation = bonesEntity.transform.rotation
                }else{
                    bonesEntity.position = arteriesEntity.position
                    bonesEntity.scale = arteriesEntity.scale
                    bonesEntity.transform.rotation = arteriesEntity.transform.rotation
                }
            } label: {
                Image("hideBones")
            }
            
            //scale
            Button {
                scale.toggle()
                if(scale){
                    bonesEntity.scale *= 2.0
                    arteriesEntity.scale *= 2.0
                }else{
                    bonesEntity.scale /= 2.0
                    arteriesEntity.scale /= 2.0
                }
            } label: {
                Image("RestoreSize")
            }
            
            //lock 3D
            Button {
                gestures.toggle()
                    toggleGestures(component: bonesEntity, isEnabled: gestures)
                    toggleGestures(component: arteriesEntity, isEnabled: gestures)
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
                
            } label: {
                Image("lock2d")
            }
            
            //LOCKINTO3D2
            Button {
                //auto overlap??
            } label: {
                Image("LOCKINTO3D2")
            }
        }.padding(.vertical, 20)
            .padding(.horizontal, 30)
        .glassBackgroundEffect()
        
        
    }
    
    func toggleGestures(component: Entity, isEnabled: Bool) {
        component.gestureComponent?.canDrag = isEnabled
        component.gestureComponent?.canRotate = isEnabled
        component.gestureComponent?.canScale = isEnabled
        component.gestureComponent?.pivotOnDrag = isEnabled
        component.gestureComponent?.preserveOrientationOnPivotDrag = isEnabled
    }
}

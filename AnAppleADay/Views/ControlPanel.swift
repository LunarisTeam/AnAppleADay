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
        
    var body: some View {
        
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
                Button { Task { await setMode(.inputAddress, nil) } }
                label: { Image("connect2D") }
                
                
                Button { appModel.hideBar.toggle() }
                label: { Image("lock2d") }
                
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
}

//
//  ModelView.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 14/03/25.
//

import SwiftUI
import RealityKitContent
import RealityKit

struct ModelView: View {
    
    @Environment(AppModel.self) private var appModel
    @Environment(\.setMode) private var setMode
    
    var body: some View {
        
        RealityView { content in
            content.add (appModel.bonesEntityHolder!)
            content.add(appModel.arteriesEntityHolder!)
            
        }update: { content in
            if appModel.lockTogether {
                
                print("viw transform: \(String(describing: appModel.transform?.translation.vector))")
                print("entity transform: \(appModel.bonesEntityHolder!.scenePosition)")
                

                appModel.bonesEntityHolder!.transform.translation = [Float((appModel.transform?.translation.vector.x)!/1000), -Float((appModel.transform?.translation.vector.y)!/1000), Float((appModel.transform?.translation.vector.z)!/1000)]
                //viw transform: Optional((x: 376.12383699417114, у: -3554.073749780655, z: -2274.170713424685))
                //entity transform: SIMD3<Float>(-0.38991052, 1.2001597, -1.7567779)
                
            }
            
        }.installGestures()
            .onAppear {
                Task { await setMode(.controlPanel, nil) }
            }
        
    }
}

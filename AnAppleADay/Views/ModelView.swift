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
    
    let headAnchorRoot: Entity = Entity()
    let headPositionedEntitiesRoot: Entity = Entity()
    
    var body: some View {
        
        RealityView { content in
            
            guard let bones = appModel.bonesEntityHolder else {
                print("Bones failed to load")
                return
            }
            content.add(bones)
            guard let arteries = appModel.arteriesEntityHolder else {
                print("Arteries failed to load")
                return
            }
            content.add(arteries)
            
            // The head anchor to be used as reference for position reset
            content.add(headAnchorRoot)
            appModel.headAnchorPositionHolder = headAnchorRoot
        } update: { content in
            
            guard let bonesEntity = appModel.bonesEntityHolder,
                  let windowPosition = appModel.windowPosition else { return }
            
            if appModel.lockElements {
                
                //MARK: This does not work as intended
                
                bonesEntity.transform.translation = [
                    Float(windowPosition.translation.vector.x / 1360),
                    -Float(windowPosition.translation.vector.y / 1500),
                    Float(windowPosition.translation.vector.z / 1000)
                ]
                
                print("Window x, \(String(describing: windowPosition.translation.vector.x)), entity x: \(appModel.bonesEntityHolder!.scenePosition.x)")
                print("Window y, \(String(describing: windowPosition.translation.vector.y)), entity y: \(appModel.bonesEntityHolder!.scenePosition.y)")
                print("Window z, \(String(describing: windowPosition.translation.vector.z)), entity z: \(appModel.bonesEntityHolder!.scenePosition.z)")
                //viw transform: Optional(SIMD3<Double>(-338.0, -275.0, 0.0))
                // entity transform: SIMD3<Float>(-0.38991052, 1.2001597, -1.7567779)
            }
        }
        .installGestures()
        .onAppear {
            Task { await setMode(.controlPanel, nil) }
        }
        .onChange(of: appModel.mustResetPosition) { _, newValue in
            if newValue { appModel.resetModelPosition() }
        }
    }
    
}

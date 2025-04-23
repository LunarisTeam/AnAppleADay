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
    
    var body: some View {
        
        RealityView { content in
            
            appModel.realityContent = content
            
            guard let bones = appModel.bonesEntityHolder else {
                print("Bones failed to load")
                return
            }

            bones.name = "bones"
            content.add(bones)
            
        } update: { content in
            if appModel.mustShowBox { appModel.showBoundingBox() }
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

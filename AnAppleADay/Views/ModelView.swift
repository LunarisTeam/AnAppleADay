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
                        
            guard let bones = appModel.bonesEntityHolder else {
                print("Bones failed to load")
                return
            }

            bones.name = "bones"
            content.add(bones)
        
        } update: { content in
            
            if appModel.mustShowBox { appModel.showBoundingBox() }
            
            if let video = appModel.videoEntityHolder {
                video.name = "video"
                content.add(video)
                
            } else if let video = content.entities.first(where: { $0.name == "video" }) {
                content.remove(video)
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

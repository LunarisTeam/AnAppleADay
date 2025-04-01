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
            content.add(appModel.bonesEntityHolder!)
            content.add(appModel.arteriesEntityHolder!)
        }
        .installGestures()
    }
}

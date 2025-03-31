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
    
//    let dataSet: DicomDataSet
    
    @Environment(\.setMode) private var setMode
    
    @State private var error: Error? = nil
    @State private var bonesEntity: Entity? = nil
    @State private var arteriesEntity: Entity? = nil
    @State private var scale: Bool = false
    @State private var bonesCenter: SIMD3<Float> = .zero
    @State private var arteriesCenter: SIMD3<Float> = .zero
    @State private var isLoading: Bool = true
    
    var body: some View {
        RealityView { content in
            content.add(appModel.bonesEntityHolder!)
            content.add(appModel.arteriesEntityHolder!)
        }
        .installGestures()
        
    }
}

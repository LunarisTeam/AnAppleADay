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
    
    let dataSet: DicomDataSet
    
    @Environment(\.setMode) private var setMode
    
    @State private var error: Error? = nil
    @State private var bonesEntity: Entity? = nil
    @State private var arteriesEntity: Entity? = nil
    @State private var scale: Bool = false
    @State private var bonesCenter: SIMD3<Float> = .zero
    @State private var arteriesCenter: SIMD3<Float> = .zero
    
    var body: some View {
        
        RealityView { content, attachments in
            appModel.dataSetHolder = dataSet
            Task { @MainActor in
                
                await appModel.setUpBonesEntity()
                await appModel.setUpArteriesEntity()
                bonesEntity = appModel.bonesEntityHolder
            }
            
            
        
            
        } update: { content, attachments in
            
            if let progress = attachments.entity(for: "Progress") {
                progress.position = [-bonesCenter.x, -bonesCenter.y+1.5, -bonesCenter.z-1.5]
                content.add(progress)
            }
            
            
            
            if let controlPanelAtt = attachments.entity(for: "ControlPanel") {
                controlPanelAtt.position = [-bonesCenter.x+0.5, -bonesCenter.y+1.3, -bonesCenter.z-1]
                content.add(controlPanelAtt)
                //                          bonesEntity?.addChild(awindowAttachment)
            }
        } attachments: {
            Attachment(id: "ControlPanel") {
                if let bonesEntity, let arteriesEntity {
                    ControlPanel(bonesEntity: bonesEntity, arteriesEntity: arteriesEntity, scale: $scale, dataSet: dataSet)
                }
            }
            
            Attachment(id: "Progress") {
                if let error {
                    ErrorView(error: error)
                    
                } else if bonesEntity == nil ||
                            arteriesEntity == nil { ProgressModelView() }
            }
            

            
            
//                        bonesEntity?.addChild(awindowAttachment)
        } placeholder: {
            if let error {
                ErrorView(error: error)
            } else {
                ProgressModelView()
            }
        } attachments: {
            Attachment(id: "ControlPanel") {
                if let bonesEntity, let arteriesEntity {
                    ControlPanel(scale: $scale, bonesEntity: bonesEntity, arteriesEntity: arteriesEntity)
                }
            }
            

        }
        .installGestures()
        .onChange(of: appModel.bonesEntityHolder) { _, newValue in
            bonesEntity = newValue
        }
        
    }
}

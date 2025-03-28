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
            
            Task.detached(priority: .utility) {
                do {
                    let bonesEntity = try await generateEntity(
                        300.0,
                        .white,
                        [0, 150, 50, 175, 500, 625],
                        [0, 50, 500]
                    )
                    let arteriesEntity = try await generateEntity(
                        650.0,
                        .red,
                        [60, 150, 100, 175, 500, 625],
                        [0, 50, 500]
                    )
                    
                    await MainActor.run {
                        arteriesEntity.isEnabled = false
                        bonesEntity.scale /= 2
                        self.bonesEntity = bonesEntity
                        var boundingBox = bonesEntity.visualBounds(relativeTo: nil)
                        self.bonesCenter = boundingBox.center
                        
                        arteriesEntity.scale /= 2
                        self.arteriesEntity = arteriesEntity
                        boundingBox = arteriesEntity.visualBounds(relativeTo: nil)
                        self.arteriesCenter = boundingBox.center
                    }
                    
                } catch { await MainActor.run { self.error = error } }
            }
            
        } update: { content, attachments in
            
            if let progress = attachments.entity(for: "Progress") {
                progress.position = [-bonesCenter.x, -bonesCenter.y+1.5, -bonesCenter.z-1.5]
                content.add(progress)
            }
            
            if let bonesEntity {
                
                bonesEntity.components.set(InputTargetComponent(allowedInputTypes: .all))
                
                bonesEntity.generateCollisionShapes(recursive: true)
                
                
                bonesEntity.components.set(ObjComponent())
                
                
                bonesEntity.position = [-bonesCenter.x, -bonesCenter.y+1.5, -bonesCenter.z-1.5]
                content.add(bonesEntity)
                
            }
            
            
            
            if let arteriesEntity {
                
                arteriesEntity.components.set(InputTargetComponent(allowedInputTypes: .all))
                arteriesEntity.generateCollisionShapes(recursive: true)
                arteriesEntity.components.set(ObjComponent())
                
                arteriesEntity.position = [-arteriesCenter.x, -arteriesCenter.y+1.5, -arteriesCenter.z-1.5]
                content.add(arteriesEntity)
            }
            
            
            if let controlPanelAtt = attachments.entity(for: "ControlPanel") {
                controlPanelAtt.position = [-bonesCenter.x+0.5, -bonesCenter.y+1.3, -bonesCenter.z-1]
                content.add(controlPanelAtt)
                //                          bonesEntity?.addChild(awindowAttachment)
            }
        } attachments: {
            Attachment(id: "ControlPanel") {
                if let bonesEntity, let arteriesEntity {
                    controlPanel(bonesEntity: bonesEntity, arteriesEntity: arteriesEntity, scale: $scale)
                }
            }
            
            Attachment(id: "Progress") {
                if let error {
                    ErrorView(error: error)
                    
                } else if bonesEntity == nil ||
                            arteriesEntity == nil { ProgressModelView() }
            }
            
//            Button {
//                Task{
//                    await setMode(.xRayFeed, nil)
//                }
//                
//            } label: {
//                Text("Open Video Player")
//            }
            
            
        }
        .installGestures()
        
        Button {
            Task{
                await setMode(.xRayFeed, nil)
            }
            
        } label: {
            Text("Open Video Player")
        }
        
    }
    
    func generateEntity(
        _ threshold: Double,
        _ color: UIColor,
        _ box: [Double],
        _ translation: [Double]
        
    ) async throws -> Entity {
        
        let visualizationToolkit: VisualizationToolkit = try .init()
        
        let dicom3DURL: URL = try visualizationToolkit.generateDICOM(
            dataSet: dataSet,
            threshold: threshold,
            boxBounds: box,
            translationBounds: translation
        )
        
        let modelEntity = try await ModelEntity(contentsOf: dicom3DURL)
        
        modelEntity.model?.materials = [
            SimpleMaterial(color: color, isMetallic: false)
        ]
        return modelEntity
    }
    
}

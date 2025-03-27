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
    
    @State private var error: Error? = nil
    
    @State private var bonesEntity: Entity? = nil
    @State private var arteriesEntity: Entity? = nil
    @State private var scale: Bool = false
    
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
                        self.bonesEntity = bonesEntity
                        self.arteriesEntity = arteriesEntity
                    }
                    
                } catch { await MainActor.run { self.error = error } }
            }
            
            
            
            
            
        } update: { content, attachments in
            
            if let bonesEntity {
                let bones = bonesEntity as! ModelEntity
                bonesEntity.components.set(InputTargetComponent(allowedInputTypes: .all))
                //entity mesh collision shape
                bonesEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateConvex(from: bones.model!.mesh)],
                                                              mode: .default,
                                                              filter: .default))
                bonesEntity.components.set(ObjComponent())
                bonesEntity.scale /= 2
                //                                bonesEntity.position = [0, 0, 0]
                content.add(bonesEntity)
            }
            
            if let arteriesEntity {
                let arteries = arteriesEntity as! ModelEntity
                arteriesEntity.components.set(InputTargetComponent(allowedInputTypes: .all))
                //entity mesh collision shape
                arteriesEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateConvex(from: arteries.model!.mesh)],
                                                                 mode: .default,
                                                                 filter: .default))
                arteriesEntity.components.set(ObjComponent())
                arteriesEntity.scale /= 2
                //                arteriesEntity.position = [0, 0, 0]
                content.add(arteriesEntity)
            }
            
            
            if let awindowAttachment = attachments.entity(for: "ControlPanel") {
                
                if let bonesEntity, let arteriesEntity {
                    
                    if(bonesEntity.isEnabled){
                        let yPosition=bonesEntity.position.y + 1
                        awindowAttachment.position = [bonesEntity.position.x, yPosition, bonesEntity.position.z]
                        content.add(awindowAttachment)
                    }else{
                        let yPosition=arteriesEntity.position.y + 1
                        awindowAttachment.position = [arteriesEntity.position.x, yPosition, arteriesEntity.position.z]
                        content.add(awindowAttachment)
                    }
                }
            }
            
        }attachments: {
            Attachment(id: "ControlPanel") {
                if let bonesEntity, let arteriesEntity {
                    controlPanel(bonesEntity: bonesEntity, arteriesEntity: arteriesEntity, scale: $scale)
                }
            }
        }.installGestures()
            .overlay {
                if let error {
                    ErrorView(error: error)
                    
                } else if bonesEntity == nil ||
                            arteriesEntity == nil { ProgressModelView() }
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
            fromDirectory: dataSet.url,
            withName: dataSet.name + "-\(threshold)",
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

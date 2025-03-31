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
    @State private var bonesCenter: SIMD3<Float> = .zero
    @State private var arteriesCenter: SIMD3<Float> = .zero
    @Environment(AppModel.self) private var appModel
    
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
                        var boundingBox = bonesEntity.visualBounds(relativeTo: nil)
                        self.bonesCenter = boundingBox.center
                        bonesEntity.transform.rotation = simd_quatf(angle: 45, axis: [1, 0, 0])
                        bonesEntity.position = [-bonesCenter.x, -bonesCenter.y+1.5, -bonesCenter.z-1.5]
                        appModel.bonesEntity = bonesEntity
                       

                        arteriesEntity.scale /= 2
                        appModel.arteriesEntity = arteriesEntity
                        boundingBox = arteriesEntity.visualBounds(relativeTo: nil)
                        self.arteriesCenter = boundingBox.center
                        arteriesEntity.position = [-bonesCenter.x, -bonesCenter.y+1.5, -bonesCenter.z-1.5]
                        appModel.arteriesEntity = arteriesEntity
                    }
                    
                } catch { await MainActor.run { self.error = error } }
            }
            
            
            Task {
                await setMode(.controlPanel, nil)
            }
            
        }
        update: { content, attachments in
            
            if let progress = attachments.entity(for: "Progress") {
                progress.position = [-bonesCenter.x, -bonesCenter.y+1.5, -bonesCenter.z-1.5]
                content.add(progress)
            }
            
            if let bonesEntity = appModel.bonesEntity {
                
                bonesEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
                bonesEntity.generateCollisionShapes(recursive: true)
                bonesEntity.components.set(ObjComponent())
                content.add(bonesEntity)
                
            }
            
            
            
            if let arteriesEntity = appModel.arteriesEntity {
                
                arteriesEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
                arteriesEntity.generateCollisionShapes(recursive: true)
                arteriesEntity.components.set(ObjComponent())
                content.add(arteriesEntity)
            }

        } attachments: {
            Attachment(id: "Progress") {
                if let error {
                    ErrorView(error: error)
                    
                } else if appModel.bonesEntity == nil ||
                            appModel.arteriesEntity == nil { ProgressModelView() }
            }
        }
        .installGestures()
        
        
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

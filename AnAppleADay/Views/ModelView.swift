//
//  ModelView.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 14/03/25.
//

import SwiftUI

import RealityKit

struct ModelView: View {
            
    let dataSet: DicomDataSet
    
    @State private var error: Error? = nil
    @Environment(\.setMode) private var setMode
    @State private var bonesEntity: Entity? = nil
    @State private var arteriesEntity: Entity? = nil
    
    var body: some View {
        
        RealityView { _ in
            
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
            
        } update: { content in
            
            if let bonesEntity {
                bonesEntity.transform.scale = [0.003, 0.003, 0.003]
                bonesEntity.transform.rotation = .init(angle: -.pi*1.5, axis: [1, 0, 0])
                content.add(bonesEntity)
            }
            
            if let arteriesEntity {
                arteriesEntity.transform.scale = [0.003, 0.003, 0.003]
                arteriesEntity.transform.rotation = .init(angle: -.pi*1.5, axis: [1, 0, 0])
                content.add(arteriesEntity)
            }
        }
        .overlay {
            if let error {
                ErrorView(error: error)
                
            } else if bonesEntity == nil ||
                      arteriesEntity == nil { ProgressModelView() }
        }
        .ornament(attachmentAnchor: .scene(.bottomFront)) {
            
            if let bonesEntity, let arteriesEntity {
                
                Button("Toggle Bones/Arteries") {
                    bonesEntity.isEnabled.toggle()
                    arteriesEntity.isEnabled.toggle()
                }
                .glassBackgroundEffect()
            }
            
            Button {
                Task{
                    await setMode(.xRayFeed, nil)
                }
                
            } label: {
                Text("Open Video Player")
            }

            
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

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
    @State private var modelEntity: Entity? = nil
    
    var body: some View {
        
        RealityView { _ in
            
            Task.detached(priority: .utility) {
                do {
                    let modelEntity = try await bootstrap()
                    
                    await MainActor.run { self.modelEntity = modelEntity }
                    
                } catch { await MainActor.run { self.error = error } }
            }
            
        } update: { content in
            
            if let modelEntity {
                                
                modelEntity.transform.scale = [0.0015, 0.0015, 0.0015]
                
                modelEntity.transform.rotation = .init(
                    angle: -.pi*1.5,
                    axis: [1, 0, 0]
                )
                
                content.add(modelEntity)
            }
        }
        .overlay {
            if modelEntity == nil, let error {
                ErrorView(error: error)
                
            } else if modelEntity == nil { ProgressModelView() }
        }
    }
    
    func bootstrap() async throws -> Entity {
        
        let visualizationToolkit: VisualizationToolkit = try .init()
        
        let dicom3DURL: URL = try visualizationToolkit.generateDICOM(
            fromDirectory: dataSet.url,
            withName: dataSet.name,
            threshold: 300.0
        )

        let modelEntity = try await ModelEntity(contentsOf: dicom3DURL)
        
        var material = SimpleMaterial(color: .white, isMetallic: false)

        modelEntity.model?.materials = [material]
        
        return modelEntity
    }
}

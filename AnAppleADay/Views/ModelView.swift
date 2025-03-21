//
//  ModelView.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 14/03/25.
//

import SwiftUI

import RealityKit

struct ModelView: View {
            
    let directoryURL: URL
    
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
            fromDirectory: directoryURL,
            withName: directoryURL.lastPathComponent,
            threshold: 300.0
        )

        return try await Entity(contentsOf: dicom3DURL)
    }
}

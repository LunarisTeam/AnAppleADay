//
//  AppModel.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 28/03/25.
//

import RealityFoundation
import RealityKitContent
import SwiftUI

/// The `AppModel` serves to control the 3D and 2D components during the surgery
@MainActor @Observable
final class AppModel {
    
    var dataSetHolder: DicomDataSet? = nil
    var bonesEntityHolder: Entity? = nil
    var arteriesEntityHolder: Entity? = nil
    
    private var bonesCenter: SIMD3<Float> = .zero
    private var arteriesCenter: SIMD3<Float> = .zero
    
    private func generateEntity(
        _ threshold: Double,
        _ color: UIColor,
        _ box: [Double],
        _ translation: [Double]
        
    ) async throws -> Entity {
        
        let visualizationToolkit: VisualizationToolkit = try .init()
        
        let dicom3DURL: URL = try visualizationToolkit.generateDICOM(
            dataSet: dataSetHolder!,
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
    
    func setUpBonesEntity() async {
        guard let bonesEntity = try? await generateEntity(
            300.0,
            .white,
            [0, 150, 50, 175, 500, 625],
            [0, 50, 500]
        ) else { return }
        
        bonesEntity.scale *= 0.5
        let boundingBox = bonesEntity.visualBounds(relativeTo: nil)
        bonesCenter = boundingBox.center
        
        bonesEntity.components.set(InputTargetComponent(allowedInputTypes: .all))
        bonesEntity.generateCollisionShapes(recursive: true)
        bonesEntity.components.set(ObjComponent())
        bonesEntity.position = [-bonesCenter.x, -bonesCenter.y+1.5, -bonesCenter.z-1.5]
        
        bonesEntityHolder = bonesEntity
    }
    
    func setUpArteriesEntity() async {
        
        guard let arteriesEntity = try? await generateEntity(
            650.0,
            .red,
            [60, 150, 100, 175, 500, 625],
            [0, 50, 500]
        ) else { return }
                
        let boundingBox = arteriesEntity.visualBounds(relativeTo: nil)
        arteriesCenter = boundingBox.center
        
        arteriesEntity.isEnabled = false
        arteriesEntity.scale *= 0.5
        arteriesEntity.components.set(InputTargetComponent(allowedInputTypes: .all))
        arteriesEntity.generateCollisionShapes(recursive: true)
        arteriesEntity.components.set(ObjComponent())
        arteriesEntity.position = [-arteriesCenter.x, -arteriesCenter.y+1.5, -arteriesCenter.z-1.5]
        
        arteriesEntityHolder = arteriesEntity
    }
    
}

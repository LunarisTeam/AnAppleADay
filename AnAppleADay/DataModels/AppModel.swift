//
//  AppModel.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 28/03/25.
//

import RealityFoundation
import RealityKitContent
import SwiftUI

/// The `AppModel` serves to control the 3D and 2D components before and during the surgery
///
/// Everything is handled in the `AppModel` as per design pattern.
/// The manipulations of DICOM files and entity must be wrapped into this class
/// As per date, compatible with `Swift6 - strict concurrency`
@MainActor @Observable
final class AppModel {
        
    /// The variable holding the DICOM dataset
    var dataSetHolder: DicomDataSet? = nil
    
    /// The variable holding the bones entity in the immersive space
    var bonesEntityHolder: Entity? = nil
    
    /// Holds the position of the head of the user
    var headAnchorPositionHolder: Entity? = nil
    
    var mustResetPosition: Bool = false
    
    /// Hides the system bar overlay under the 2D window overlapping the immersive space
    var hideBar: Bool = false
    
    /// The window position that is used during the X-Ray
    var windowPosition: AffineTransform3D? = nil
    
    /// To enable the scaling of entities
    private var scale: Bool = false
    
    /// Finds the center of the bones to be subtracted manually in order to center the entity
    /// The same applies for the artieries.
    private var bonesCenter: SIMD3<Float> = .zero
    private var arteriesCenter: SIMD3<Float> = .zero
    
    /// Enables the custom gestures to be perfomed on the entity
    var enableGestures: Bool = true
    
    /// Generates a 3D model entity from the DICOM dataset.
    ///
    /// - Parameters:
    ///   - threshold: The value used for DICOM segmentation, more in the VTK documentation.
    ///   - color: The color to apply to the entity's material.
    ///   - box: The box bounds used for visualization, as per date trimmed only to the femur.
    ///   - translation: The translation bounds for positioning.
    /// - Returns: A newly created `Entity` containing the 3D model.
    /// - Throws: An error if the DICOM generation or model loading fails.
    private func generateEntity(
        _ threshold: Double,
        _ color: UIColor,
        _ box: [Double]?,
        _ translation: [Double]?
        
    ) async throws -> Entity {
        
        let visualizationToolkit: VisualizationToolkit = try .init()
        
        guard let dataSet = dataSetHolder else {
            print("Error, dataSet unwrap failed")
            return Entity()
        }
        
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
        
        print("Model generated successfully")
        return modelEntity
    }
    
    /// Sets up the bones entity by generating it from the DICOM dataset and configuring its properties.
    ///
    /// This method applies scaling, calculates the center for proper positioning,
    /// and configures input components and collision shapes.
    private func setUpBonesEntity() async {
        
        // Currently we are trimming the model only if the submitted dataSet
        // matches a slice count of 862, which is exactly our test DataSet.
        // We would offer a UI to configure the trimming in a production scenario.
        guard let bonesEntity = try? await generateEntity(
            300.0,
            .white,
            dataSetHolder?.sliceCount == 862 ? [0, 150, 50, 175, 450, 625] : nil,
            dataSetHolder?.sliceCount == 862 ? [0, 50, 450] : nil
        ) else { return }
        
        bonesEntity.scale *= 0.5
        let boundingBox = bonesEntity.visualBounds(relativeTo: nil)
        bonesCenter = boundingBox.center
        
        bonesEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        bonesEntity.generateCollisionShapes(recursive: true)
        bonesEntity.components.set(ObjComponent())
        bonesEntity.position = [-bonesCenter.x, -bonesCenter.y+1.5, -bonesCenter.z-1.5]
        bonesEntity.transform.rotation = simd_quatf(angle: 45, axis: [1, 0, 0])
        
        bonesEntityHolder = bonesEntity
        print("bones set")
    }
    
    /// Loads both bones and arteries entities concurrently.
    ///
    /// After the entities are set up, the provided completion handler is executed.
    /// Used in the `ProgressView` to safely handle loading
    ///
    /// - Parameter completion: A closure that is called when both entities have been loaded.
    func entitiesLoaded(completion: @escaping () -> Void) async {
        async let bonesTask: () = setUpBonesEntity()
        
        _ = await (bonesTask)
        
        completion()
    }
    
    /// Toggles the enablement of gesture interactions on both the bones and arteries entities.
    ///
    /// This controls whether users can drag, rotate, or scale the entities, and whether the entity
    /// should pivot on drag. When toggled, it updates the corresponding gesture properties for each entity.
    func toggleGestures() {
        
        guard let bonesEntity = bonesEntityHolder else { return }
        
        enableGestures.toggle()
        
        bonesEntity.gestureComponent?.canDrag = enableGestures
        bonesEntity.gestureComponent?.canRotate = enableGestures
        bonesEntity.gestureComponent?.canScale = enableGestures
        bonesEntity.gestureComponent?.pivotOnDrag = enableGestures
        bonesEntity.gestureComponent?.preserveOrientationOnPivotDrag = enableGestures
    }
    
    func resetModelPosition() {
        
        guard self.mustResetPosition else { return }
        
        guard let bonesEntity = bonesEntityHolder else {
            print("Bones entity not found")
            return
        }
        
        guard let headAnchorRoot = headAnchorPositionHolder else {
            print("Could not find head anchor")
            return
        }
                
        let position = SIMD3<Float>(-0.35, 0, -2)
        
        let headAnchor = AnchorEntity(.head)
        headAnchor.anchoring.trackingMode = .once
        headAnchor.name = "headAnchor"

        headAnchorRoot.addChild(headAnchor)
        
        headAnchor.addChild(bonesEntity)
        
        // AB segment, therefore distance is B - A (where position is B)
        // There is a problem with the bonesEntity I believe regarding the real center of the entity.
        // That is why when this code is run, there is a random teleportation
        let transformPosition = Transform(translation: position - bonesEntity.position)

        headAnchor.move(to: transformPosition, relativeTo: headAnchor, duration: 2.5, timingFunction: .easeInOut)
        
        self.mustResetPosition = false
    }
}

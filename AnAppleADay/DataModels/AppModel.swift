//
//  AppModel.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 28/03/25.
//

import RealityKit
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
    
    /// Holds the position of the head of the user.
    var headAnchorPositionHolder: Entity? = nil
    
    /// Indicates whether the model position should be reset.
    var mustResetPosition: Bool = false
    
    /// Flag to control the visibility of a debug bounding box.
    var mustShowBox: Bool = false
    
    /// The entity representing the bounding box of the bones.
    var bonesBoundingBox: Entity? = nil
    
    /// The variable holding the bones entity in the immersive space
    var arteriesEntityHolder: Entity? = nil
    
    /// Hides the system bar overlay under the 2D window overlapping the immersive space
    var hideBar: Bool = false
    
    /// The window position that is used during the X-Ray
    var windowPosition: AffineTransform3D? = nil
    
    /// Locks both the entity and the window X-Ray so that they can move together
    var lockElements: Bool = false
    
    /// To enable the scaling of entities
    
    var scale: Bool = false
    
    var realityContent: RealityViewContent? = nil
    
    /// Finds the center of the bones to be subtracted manually in order to center the entity
    /// The same applies for the artieries.
    var bonesCenter: SIMD3<Float> = .zero
    var arteriesCenter: SIMD3<Float> = .zero
    
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
                
        bonesEntityHolder = bonesEntity
        print("bones set")
    }
    
    /// Sets up the arteries entity by generating it from the DICOM dataset and configuring its properties.
    ///
    /// This method applies scaling, calculates the center for proper positioning,
    /// and configures input components and collision shapes. The entity is initially disabled.
    private func setUpArteriesEntity() async {
        
        // Currently we are trimming the model only if the submitted dataSet
        // matches a slice count of 862, which is exactly our test DataSet.
        // We would offer a UI to configure the trimming in a production scenario.
        guard let arteriesEntity = try? await generateEntity(
            650.0,
            .red,
            dataSetHolder?.sliceCount == 862 ? [60, 150, 100, 175, 450, 625] : nil,
            dataSetHolder?.sliceCount == 862 ? [0, 50, 450] : nil
        ) else { return }
        
        let boundingBox = arteriesEntity.visualBounds(relativeTo: nil)
        arteriesCenter = boundingBox.center
        
        arteriesEntity.isEnabled = false
        arteriesEntity.scale *= 0.5
        arteriesEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        arteriesEntity.generateCollisionShapes(recursive: true)
        arteriesEntity.components.set(ObjComponent())
        arteriesEntity.position = [-arteriesCenter.x, -arteriesCenter.y + 1.5, -arteriesCenter.z - 1.5]
        
        arteriesEntityHolder = arteriesEntity
        print("arteries set")
    }
    
    /// Loads both bones and arteries entities concurrently.
    ///
    /// After the entities are set up, the provided completion handler is executed.
    /// Used in the `ProgressView` to safely handle loading
    ///
    /// - Parameter completion: A closure that is called when both entities have been loaded.
    func entitiesLoaded(completion: @escaping () -> Void) async {
        async let bonesTask: () = setUpBonesEntity()
        async let arteriesTask: () = setUpArteriesEntity()
        
        _ = await (bonesTask, arteriesTask)
        
        completion()
    }
    
    /// Toggles the visibility of the bones and arteries entities.
    ///
    /// When one entity is toggled off, the other entity's position, scale, and rotation
    /// are set to match the currently visible entity to maintain alignment.
    func bonesArteriesToggle() {
        
        guard let bonesEntity = bonesEntityHolder, let arteriesEntity = arteriesEntityHolder else { return }
        print("checks passed")
        
        bonesEntity.isEnabled.toggle()
        arteriesEntity.isEnabled.toggle()
        
        if !bonesEntity.isEnabled {
            arteriesEntity.position = bonesEntity.position
            arteriesEntity.scale = bonesEntity.scale
            arteriesEntity.transform.rotation = bonesEntity.transform.rotation
        } else {
            bonesEntity.position = arteriesEntity.position
            bonesEntity.scale = arteriesEntity.scale
            bonesEntity.transform.rotation = arteriesEntity.transform.rotation
        }
    }
    
    /// Scales both entities up or down based on the current scaling state.
    ///
    /// Serves to double or return to the default size of the 3D model.
    func scaleEntities() {
        scale.toggle()
        
        if scale {
            bonesEntityHolder?.scale *= 2.0
            arteriesEntityHolder?.scale *= 2.0
        } else {
            bonesEntityHolder?.scale *= 0.5
            arteriesEntityHolder?.scale *= 0.5
        }
    }
    
    /// Toggles the enablement of gesture interactions on both the bones and arteries entities.
    ///
    /// This controls whether users can drag, rotate, or scale the entities, and whether the entity
    /// should pivot on drag. When toggled, it updates the corresponding gesture properties for each entity.
    func toggleGestures() {
        
        enableGestures.toggle()
        
        guard let bonesEntity = bonesEntityHolder, let arteriesEntity = arteriesEntityHolder else { return }
        
        bonesEntity.gestureComponent?.canDrag = enableGestures
        bonesEntity.gestureComponent?.canRotate = enableGestures
        bonesEntity.gestureComponent?.canScale = enableGestures
        bonesEntity.gestureComponent?.pivotOnDrag = enableGestures
        bonesEntity.gestureComponent?.preserveOrientationOnPivotDrag = enableGestures
        
        arteriesEntity.gestureComponent?.canDrag = enableGestures
        arteriesEntity.gestureComponent?.canRotate = enableGestures
        arteriesEntity.gestureComponent?.canScale = enableGestures
        arteriesEntity.gestureComponent?.pivotOnDrag = enableGestures
        arteriesEntity.gestureComponent?.preserveOrientationOnPivotDrag = enableGestures
    }
    
    func lockTogether() {
        
        lockElements.toggle()
        
        guard let bonesEntity = bonesEntityHolder else { return }
        
        bonesEntity.gestureComponent?.canDrag = lockElements
        bonesEntity.gestureComponent?.canRotate = lockElements
        bonesEntity.gestureComponent?.canScale = lockElements
        bonesEntity.gestureComponent?.pivotOnDrag = lockElements
        bonesEntity.gestureComponent?.preserveOrientationOnPivotDrag = lockElements
    }
    
    func resetModelPosition() {
        
        guard self.mustResetPosition else { return }
        
        guard let bonesEntity = bonesEntityHolder else {
            print("Bones entity not found")
            return
        }
        
        guard let arteriesEntity = arteriesEntityHolder else {
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
        
        let headPositionedEntitiesRoot = Entity()
        
        headAnchor.addChild(bonesEntity)
        
        // AB segment, therefore distance is B - A (where position is B)
        // There is a problem with the bonesEntity I believe regarding the real center of the entity.
        // That is why when this code is run, there is a random teleportation
        let transformPosition = Transform(translation: position - bonesEntity.position)
        
        headAnchor.move(to: transformPosition, relativeTo: headAnchor, duration: 2.5, timingFunction: .easeInOut)
        
        self.mustResetPosition = false
    }
    
    /// Toggles the display of the debug bounding box for the bones entity.
    func toggleBoundingBox() {
        mustShowBox.toggle()
        showBoundingBox()
    }
    
    /// Manages the display of the bounding box by creating it if needed and toggling its visibility.
    func showBoundingBox() {
        guard let bonesEntity = bonesEntityHolder else {
            print("Bones entity not found")
            return
        }

        if bonesBoundingBox == nil {
            print("Creating bounding box")
            createBoundingBox()
        }

        guard let box = bonesBoundingBox else { return }

//        if !bonesEntity.children.contains(box) { bonesEntity.addChild(box, preservingWorldTransform: true) }
        
        box.isEnabled = mustShowBox        
    }
    
    /// Creates the bounding box entity for the bones if it does not already exist.
    private func createBoundingBox() {
        guard bonesBoundingBox == nil else { return }
        
        guard let bonesEntity = bonesEntityHolder else {
            print("Bones entity not found")
            return
        }
        
        let bounds = bonesEntity.visualBounds(relativeTo: nil)

        let size = bounds.extents
        let center = bounds.center
        
        let boundingBox = createWireframeBoundingBox(center: center, size: size)
        boundingBox.name = "BoundingBox"
        
        bonesEntity.addChild(boundingBox, preservingWorldTransform: true)
                
        bonesBoundingBox = boundingBox
        
    }
    
    /// Creates a wireframe bounding box entity given a center, size, and optional line thickness.
    ///
    /// - Parameters:
    ///   - center: The center of the bounding box.
    ///   - size: The size (extents) of the bounding box.
    ///   - thickness: The thickness of the bounding box lines. Default is 0.0025.
    /// - Returns: An `Entity` representing the wireframe bounding box.
    private func createWireframeBoundingBox(
        center: SIMD3<Float>,
        size: SIMD3<Float>,
        thickness: Float = 0.0025
    ) -> Entity {
        
        // some maths here, move along if not interested...
        let hx = size.x / 2
        let hy = size.y / 2
        let hz = size.z / 2
        
        let c0 = SIMD3<Float>(center.x - hx, center.y - hy, center.z - hz)
        let c1 = SIMD3<Float>(center.x + hx, center.y - hy, center.z - hz)
        let c2 = SIMD3<Float>(center.x + hx, center.y - hy, center.z + hz)
        let c3 = SIMD3<Float>(center.x - hx, center.y - hy, center.z + hz)
        let c4 = SIMD3<Float>(center.x - hx, center.y + hy, center.z - hz)
        let c5 = SIMD3<Float>(center.x + hx, center.y + hy, center.z - hz)
        let c6 = SIMD3<Float>(center.x + hx, center.y + hy, center.z + hz)
        let c7 = SIMD3<Float>(center.x - hx, center.y + hy, center.z + hz)
        
        let edges: [(SIMD3<Float>, SIMD3<Float>)] = [
            (c0, c1), (c1, c2), (c2, c3), (c3, c0), // bottom face
            (c4, c5), (c5, c6), (c6, c7), (c7, c4), // top face
            (c0, c4), (c1, c5), (c2, c6), (c3, c7)  // vertical edges
        ]
        
        let wireframeEntity = Entity()
        for (start, end) in edges {
            let edgeEntity = createEdge(from: start, to: end, thickness: thickness)
            wireframeEntity.addChild(edgeEntity)
        }
        return wireframeEntity
    }
    
    /// Creates an edge of the bounding box as a cylinder connecting two given points.
    ///
    /// - Parameters:
    ///   - start: The start point of the edge.
    ///   - end: The end point of the edge.
    ///   - thickness: The radius (thickness) of the edge cylinder.
    /// - Returns: A `ModelEntity` representing the cylindrical edge.
    private func createEdge(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        thickness: Float
    ) -> ModelEntity {
        
        //still more maths...
        let vector = end - start
        let length = simd_length(vector)
        
        let cylinderMesh = MeshResource.generateCylinder(height: length, radius: thickness)
        let material = SimpleMaterial(color: .green.withAlphaComponent(0.5), isMetallic: false)
        let cylinderEntity = ModelEntity(mesh: cylinderMesh, materials: [material])
        
        let midPoint = (start + end) / 2
        cylinderEntity.position = midPoint
        
        let up = SIMD3<Float>(0, 1, 0)
        let direction = normalize(vector)
        let rotation = simd_quatf(from: up, to: direction)
        cylinderEntity.orientation = rotation
        
        return cylinderEntity
    }
}

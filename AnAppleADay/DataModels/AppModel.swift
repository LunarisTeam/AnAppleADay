//
//  AppModel.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 28/03/25.
//

import RealityKit
import RealityKitContent
import SwiftUI
import AVFoundation

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
    var bonesEntityHolder: Entity? = nil {
        didSet { enableBonesGestures = true }
    }
    
    /// The variable holding the bones entity in the immersive space
    var videoEntityHolder: Entity? {
        didSet { enableVideoGestures = true }
    }
    
    /// Holds the position of the head of the user.
    var headAnchorPositionHolder: Entity? = nil
    
    var headPositionedEntitiesHolder: Entity? = nil
    
    /// Indicates whether the model position should be reset.
    var mustResetPosition: Bool = false

    /// Flag to control the visibility of a debug bounding box.
    var mustShowBox: Bool = false
    
    /// The entity representing the bounding box of the bones.
    var bonesBoundingBox: Entity? = nil
    
    /// To enable the scaling of entities
    var scale: Bool = false
    
    /// A flag indicating whether the input window is currently open.
    var isInputWindowOpen: Bool = false
    
    /// Finds the center of the bones to be subtracted manually in order to center the entity
    /// The same applies for the artieries.
    var bonesCenter: SIMD3<Float> = .zero
    
    /// Enables the custom gestures to be perfomed on the entity
    var enableBonesGestures: Bool = true {
        didSet { bonesEntityHolder?.setDirectGestures(enabled: enableBonesGestures) }
    }
    
    var enableVideoGestures: Bool = true {
        didSet { videoEntityHolder?.setDirectGestures(enabled: enableVideoGestures) }
    }
    
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
        
        guard let headPositionedEntitiesRoot = headPositionedEntitiesHolder else {
            print("Could not find head anchor")
            return
        }
        
        let position = SIMD3<Float>(-0.2, 0, -1.2)
        
        let headAnchor = AnchorEntity(.head)
        headAnchor.anchoring.trackingMode = .once
        headAnchor.name = "headAnchor"
        
        headAnchorRoot.addChild(headAnchor)
        headPositionedEntitiesRoot.addChild(bonesEntity)
        
        bonesEntity.setPosition(position, relativeTo: headPositionedEntitiesRoot)
        print("Bones entity, positioned: \(bonesEntity.position)")
        
        headAnchor.addChild(headPositionedEntitiesRoot)
        headPositionedEntitiesRoot.setPosition(position, relativeTo: headAnchor)
        
        self.mustResetPosition = false
    }
    
    /// Toggles the display of the debug bounding box for the bones entity.
    func toggleBoundingBox() {
        mustShowBox.toggle()
        showBoundingBox()
    }
    
    /// Manages the display of the bounding box by creating it if needed and toggling its visibility.
    func showBoundingBox() {
        guard bonesEntityHolder != nil else {
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
    
    func createVideoEntity(address: String, port: String) async {
        
        let url = URL(string: "http://\(address):\(port)/xrayVideo.m3u8")!
        let player = AVPlayer(url: url)
        player.play()

        let material = VideoMaterial(avPlayer: player)
        
        guard let imageEntity = try? await Entity(
            named: "Image",
            in: realityKitContentBundle
        ) else { return }
        
        if let cube = imageEntity.findEntity(named: "Cube"),
           var modelComponent = cube.components[ModelComponent.self] {
            modelComponent.materials = [material]
            cube.components[ModelComponent.self] = modelComponent
            cube.position = [-bonesCenter.x, -bonesCenter.y + 1.5, -bonesCenter.z - 1.5]
            
            videoEntityHolder = cube
        }
    }
}

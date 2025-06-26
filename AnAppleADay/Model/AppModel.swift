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

/// The `AppModel` class controls the 3D and 2D components before and during the surgical visualization process.
///
/// This class acts as the main coordinator for manipulating entities and DICOM datasets,
/// following a centralized design pattern. All operations related to the immersive scene,
/// including loading, positioning, and gesture control of entities, are handled here.
///
/// This class is compatible with Swift 6 and strict concurrency.
@MainActor @Observable
final class AppModel {

    /// A reference to the root content entity in the RealityView scene.
    var contentReference: RealityViewContent?

    /// Holds the currently loaded DICOM dataset.
    var dataSetHolder: DicomDataSet? = nil

    /// Holds the bones entity in the immersive scene.
    var bonesEntityHolder: Entity? = nil {
        didSet { enableBonesGestures = true }
    }

    /// Holds the video entity displayed in the immersive scene.
    var videoEntityHolder: VideoEntity?

    /// Holds the anchor representing the user’s head position.
    /// Used to properly position and reparent entities in the scene.
    var headAnchorPositionHolder: Entity? = nil

    /// The container for entities positioned relative to the user’s head.
    var headPositionedEntitiesHolder: Entity? = nil

    /// Flag indicating whether the bones model should be repositioned.
    var mustResetPosition: Bool = false

    /// Flag indicating whether a debug bounding box should be shown.
    var mustShowBox: Bool = false

    /// The wireframe bounding box entity around the bones.
    var bonesBoundingBox: Entity? = nil

    /// Flag controlling whether entities are currently scalable by user gestures.
    var scale: Bool = false

    /// Flag indicating whether the input window is currently visible.
    var isInputWindowOpen: Bool = false

    /// The center point of the bones, used for alignment and positioning.
    var bonesCenter: SIMD3<Float> = .zero

    /// Determines whether the bones and video entities are parented together.
    ///
    /// When set to `true`, disables gesture interaction on the bones entity and reparents it
    /// to the video entity. When set to `false`, reverses the process.
    var entitiesLockedTogether: Bool = false {
        didSet {
            guard let videoEntityHolder,
                  let bonesEntityHolder,
                  let contentReference else { return }

            if entitiesLockedTogether {
                bonesEntityHolder.setDirectGestures(enabled: false)
                videoEntityHolder.addChild(bonesEntityHolder, preservingWorldTransform: true)
            } else {
                videoEntityHolder.removeChild(bonesEntityHolder)
                bonesEntityHolder.setDirectGestures(enabled: true)
                contentReference.add(bonesEntityHolder)
            }
        }
    }

    /// Enables or disables custom gesture interaction on the bones entity.
    var enableBonesGestures: Bool = true {
        didSet { bonesEntityHolder?.setDirectGestures(enabled: enableBonesGestures) }
    }

    /// Generates a 3D model entity from the provided DICOM dataset.
    ///
    /// - Parameters:
    ///   - threshold: The segmentation threshold for the DICOM volume.
    ///   - color: The color to apply to the generated entity.
    ///   - box: Optional bounding box limits to trim the volume.
    ///   - translation: Optional translation values for positioning the entity.
    /// - Returns: A new `Entity` representing the 3D model.
    /// - Throws: An error if DICOM processing or model loading fails.
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

    /// Configures the bones entity by generating it from the DICOM dataset.
    ///
    /// Applies trimming, positioning, scaling, input and collision components.
    private func setUpBonesEntity() async {
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
        bonesEntity.position = [-bonesCenter.x, -bonesCenter.y + 1.5, -bonesCenter.z - 1.5]

        bonesEntityHolder = bonesEntity
        print("bones set")
    }

    /// Loads all required 3D entities (bones and arteries) and invokes a completion handler once done.
    ///
    /// - Parameter completion: A closure to execute after all entities have been successfully loaded.
    func entitiesLoaded(completion: @escaping () -> Void) async {
        async let bonesTask: () = setUpBonesEntity()
        _ = await (bonesTask)
        completion()
    }

    /// Resets the bones entity's position relative to the user's head.
    ///
    /// This method handles complex reparenting of entities, which should be done carefully
    /// to avoid breaking scene structure.
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

        headAnchorRoot.addChild(headAnchor)
        headPositionedEntitiesRoot.addChild(bonesEntity)

        bonesEntity.setPosition(position, relativeTo: headPositionedEntitiesRoot)

        headAnchor.addChild(headPositionedEntitiesRoot)
        headPositionedEntitiesRoot.setPosition(position, relativeTo: headAnchor)

        self.mustResetPosition = false
    }

    /// Toggles the visibility of the debug bounding box on the bones entity.
    func toggleBoundingBox() {
        mustShowBox.toggle()
        showBoundingBox()
    }

    /// Displays the bounding box around the bones entity if enabled.
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
        box.isEnabled = mustShowBox
    }

    /// Creates a wireframe bounding box entity based on the bones entity's dimensions.
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

        bonesEntity.addChild(boundingBox, preservingWorldTransform: true)
        bonesBoundingBox = boundingBox
    }

    /// Creates a wireframe bounding box entity given a center, size, and optional thickness.
    ///
    /// - Parameters:
    ///   - center: The center point of the bounding box.
    ///   - size: The bounding box dimensions.
    ///   - thickness: The line thickness for the edges. Default is 0.0025.
    /// - Returns: A composed wireframe `Entity`.
    private func createWireframeBoundingBox(
        center: SIMD3<Float>,
        size: SIMD3<Float>,
        thickness: Float = 0.0025
    ) -> Entity {
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
            (c0, c1), (c1, c2), (c2, c3), (c3, c0),
            (c4, c5), (c5, c6), (c6, c7), (c7, c4),
            (c0, c4), (c1, c5), (c2, c6), (c3, c7)
        ]

        let wireframeEntity = Entity()
        for (start, end) in edges {
            let edgeEntity = createEdge(from: start, to: end, thickness: thickness)
            wireframeEntity.addChild(edgeEntity)
        }
        return wireframeEntity
    }

    /// Creates a cylindrical edge between two points in 3D space.
    ///
    /// - Parameters:
    ///   - start: The start position of the edge.
    ///   - end: The end position of the edge.
    ///   - thickness: The radius of the cylinder.
    /// - Returns: A `ModelEntity` representing the edge.
    private func createEdge(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        thickness: Float
    ) -> ModelEntity {
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

    /// Creates and positions a video entity in the scene using a server-side video stream.
    ///
    /// - Parameters:
    ///   - address: The IP address of the server.
    ///   - port: The port of the server.
    func createVideoEntity(address: String, port: String) async {
        guard let entity = try? VideoEntity(address: address, port: port, fileName: "xrayVideo.m3u8") else {
            return
        }

        try? await entity.setup(position: .init(
            x: -bonesCenter.x,
            y: -bonesCenter.y + 1.5,
            z: -bonesCenter.z - 1.5
        ))

        self.videoEntityHolder = entity
    }
}

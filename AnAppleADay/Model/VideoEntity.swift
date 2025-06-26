//
//  VideoEntity.swift
//  AnAppleADay
//
//  Created by Giuseppe Rocco on 07/05/25.
//

import AVFoundation
import RealityKit
import RealityKitContent

/// A RealityKit entity that displays a video with an optional visual frame,
/// supporting locking and unlocking behavior for user interactions.
///
/// `VideoEntity` renders video content using an `AVPlayer` on a plane and
/// adds a surrounding frame to indicate lock state. When locked, interactions
/// are disabled and the frame shows a "locked" appearance.
///
/// - Important: This class must be initialized using `init(address:port:fileName:)`.
@MainActor @Observable
final class VideoEntity: Entity {

    /// The underlying video player providing video content.
    let avPlayer: AVPlayer

    /// Indicates whether the entity is locked (non-interactive).
    var isLocked: Bool = true

    /// The decorative frame entity surrounding the video plane.
    private var frameEntity: ModelEntity?

    /// The video plane displaying the AVPlayer content.
    private var videoEntity: Entity?

    /// Errors thrown during initialization or setup.
    enum Error: Swift.Error {
        /// Indicates the video URL could not be created.
        case failedToLoadVideo
    }

    /// Sets up the video and frame entities with the specified dimensions.
    ///
    /// - Parameters:
    ///   - width: The width of the video plane.
    ///   - height: The height of the video plane.
    /// - Throws: An error if the child entities fail to initialize.
    private func setupChilds(width: Float, height: Float) async throws {
        let videoEntity = ModelEntity(
            mesh: .generatePlane(width: width, height: height),
            materials: [VideoMaterial(avPlayer: avPlayer)]
        )

        videoEntity.position = [0, 0, 0.005]

        let frameEntity = ModelEntity(
            mesh: .generateBox(width: width * 1.25,
                               height: height * 1.25,
                               depth: 0.001)
        )

        frameEntity.position = [0, 0, 0]

        self.addChild(frameEntity); self.frameEntity = frameEntity
        self.addChild(videoEntity); self.videoEntity = videoEntity
    }

    /// Toggles the lock state of the entity.
    ///
    /// Updates the frame texture and enables or disables gesture interactions.
    ///
    /// - Throws: An error if the frame texture fails to load.
    func toggleLockState() async throws {
        guard let frameEntity else { return }
        isLocked.toggle()

        let frameTexture = try await TextureResource(
            named: isLocked ? "ImageFrameLocked" : "ImageFrame"
        )

        var frameMaterial = UnlitMaterial(texture: frameTexture)
        frameMaterial.blending = .transparent(opacity: 1.0)

        frameEntity.model?.materials = [frameMaterial]
        self.setDirectGestures(enabled: !isLocked)
    }

    /// Performs full setup of the entity including position, size, components, and video playback.
    ///
    /// - Parameter position: The world-space position where the entity should appear.
    /// - Throws: An error if the setup fails at any stage.
    func setup(position: SIMD3<Float>) async throws {
        let (width, height) = ModelEntity.scaleValuesForEntities()
        try await setupChilds(width: width, height: height)

        self.position = position
        self.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        self.components.set(ObjComponent())
        self.components.set(CollisionComponent(shapes: [
            .generateBox(width: width * 1.25,
                         height: height * 1.25,
                         depth: 0.001)
        ]))

        try await toggleLockState()
        avPlayer.play()
    }

    /// Designated initializer to create a `VideoEntity` from a network video file.
    ///
    /// - Parameters:
    ///   - address: The server address hosting the video.
    ///   - port: The port on which the server is listening.
    ///   - fileName: The name of the video file to stream.
    /// - Throws: `VideoEntity.Error.failedToLoadVideo` if the URL cannot be constructed.
    init(address: String, port: String, fileName: String) throws {
        guard let url = URL(string: "http://" + address + ":" + port + "/" + fileName) else {
            throw Error.failedToLoadVideo
        }

        self.avPlayer = AVPlayer(url: url)
        super.init()
    }

    /// Unavailable initializer. Use `init(address:port:fileName:)` instead.
    @available(*, unavailable, message: "This is VideoEntity. Use init(address:port:fileName:) instead.")
    required init() {
        fatalError("This is VideoEntity, init(address:_, port:_, fileName:_) must be used")
    }
}

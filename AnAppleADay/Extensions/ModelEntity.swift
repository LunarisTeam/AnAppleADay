//
//  ModelEntity.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 06/05/25.
//

import RealityFoundation

extension ModelEntity {
    
    /// Returns scaled width and height values for entities based on a fixed video resolution.
    ///
    /// This method calculates the physical dimensions of a video plane (or similar entity)
    /// by applying a uniform scale factor to a base video resolution of 640x480 pixels.
    ///
    /// - Returns: A tuple containing the scaled width and height as `Float` values.
    static func scaleValuesForEntities() -> (width: Float, height: Float) {
        let videoWidth: Float = 640
        let videoHeight: Float = 480
        let scaleFactor: Float = 0.0015
        return (videoWidth * scaleFactor, videoHeight * scaleFactor)
    }
}

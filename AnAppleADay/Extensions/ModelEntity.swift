//
//  ModelEntity.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 06/05/25.
//

import RealityFoundation

extension ModelEntity {
    static func scaleValuesForEntities() -> (width: Float, height: Float) {
        let videoWidth: Float = 640
        let videoHeight: Float = 480
        let scaleFactor: Float = 0.0015
        return (videoWidth * scaleFactor, videoHeight * scaleFactor)
    }
}

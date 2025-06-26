// Copyright 2025 Lunaris Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ---------------------------------------------------------------------------
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

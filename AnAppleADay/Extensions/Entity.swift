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
//  Entity.swift
//  AnAppleADay
//
//  Created by Giuseppe Rocco on 23/04/25.
//

import RealityKit

extension Entity {
    
    /// Enables or disables direct gesture interactions on the entity.
    ///
    /// This method modifies several properties of the entity’s `gestureComponent` to
    /// allow or prevent the user from directly interacting with the entity using gestures.
    /// Specifically, it controls the ability to drag, rotate, and scale the entity,
    /// as well as whether dragging affects the pivot point and maintains orientation.
    ///
    /// - Parameter enabled: A Boolean value indicating whether gestures should be enabled.
    func setDirectGestures(enabled: Bool) {
        self.gestureComponent?.canDrag = enabled
        self.gestureComponent?.canRotate = enabled
        self.gestureComponent?.canScale = enabled
        self.gestureComponent?.pivotOnDrag = enabled
        self.gestureComponent?.preserveOrientationOnPivotDrag = enabled
    }
}

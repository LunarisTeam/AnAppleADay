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
//  WindowIDs.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

import Foundation

/// A namespace for storing unique identifiers for windows and immersive spaces in the app.
///
/// These identifiers are used when referencing specific `WindowGroup`s or `ImmersiveSpace`s
/// in SwiftUI scene management, navigation, and transitions.
struct WindowIDs {

    /// The identifier for the window used to import DICOM datasets.
    static let importDicomsWindowID: String = "ImportDicoms"

    /// The identifier for the window used to generate 3D models from DICOM data.
    static let generateModelWindowID: String = "GenerateModel"

    /// The identifier for the window displaying the live X-ray (fluoroscope) feed.
    static let xRayFeedWindowID: String = "XRayFeed"

    /// The identifier for the immersive space used to render 3D models in AR/VR.
    static let immersiveSpaceID: String = "ImmersiveSpaceID"

    /// The identifier for the window where the user inputs the server address.
    static let inputAddressWindowID: String = "InputAddress"

    /// The identifier for the immersive control panel overlay.
    static let controlPanelWindowID: String = "ControlPanel"

    /// The identifier for the window shown while content is being loaded or processed.
    static let progressWindowID: String = "Progress"
}

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
//  ModelView.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 14/03/25.
//

import SwiftUI
import RealityKitContent
import RealityKit

/// A SwiftUI view that displays the immersive 3D environment using RealityKit.
///
/// `ModelView` loads and displays the 3D bones entity, optionally overlays a video entity,
/// and sets up anchor points relative to the user’s head for spatial positioning.
/// It responds to state changes in `AppModel` to dynamically update the immersive scene.
struct ModelView: View {
    
    /// The application model providing access to the entities and scene state.
    @Environment(AppModel.self) private var appModel

    /// Function used to set the current application mode.
    @Environment(\.setMode) private var setMode

    /// An anchor entity representing the user's head. Used for relative positioning of 3D content.
    let headAnchorRoot: Entity = Entity()

    /// A container entity for models that should be positioned relative to the user's head.
    let headPositionedEntitiesRoot: Entity = Entity()

    var body: some View {
        RealityView { content in
            // MARK: - Initial Scene Setup

            appModel.contentReference = content

            guard let bones = appModel.bonesEntityHolder else {
                print("Bones failed to load")
                return
            }

            bones.name = "bones"

            appModel.headAnchorPositionHolder = headAnchorRoot
            appModel.headPositionedEntitiesHolder = headPositionedEntitiesRoot

            content.add(bones)
            content.add(headAnchorRoot)
            content.add(headPositionedEntitiesRoot)

        } update: { content in
            // MARK: - Scene Update on State Changes

            if appModel.mustShowBox {
                appModel.showBoundingBox()
            }

            if let video = appModel.videoEntityHolder {
                video.name = "video"
                content.add(video)

            } else if let video = content.entities.first(where: { $0.name == "video" }) {
                content.remove(video)
            }
        }
        .installGestures()

        // MARK: - Initial View Appearance
        .onAppear {
            Task { await setMode(.controlPanel, nil) }
        }

        // MARK: - Respond to Position Reset Requests
        .onChange(of: appModel.mustResetPosition) { _, newValue in
            if newValue {
                appModel.resetModelPosition()
            }
        }
    }
}

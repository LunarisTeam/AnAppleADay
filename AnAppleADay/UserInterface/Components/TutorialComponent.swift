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
//  TutorialComponent.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 27/02/25.
//

import SwiftUI

/// A SwiftUI view that displays a tutorial step as part of an onboarding or help flow.
///
/// The component shows a step number, an image (based on the step), and a descriptive message.
/// It's designed to be reused for multiple tutorial steps, each distinguished by a `stepNumber`.
struct TutorialComponent: View {
    
    /// The current step number in the tutorial sequence.
    ///
    /// Used to determine which image and body text to display.
    let stepNumber: Int

    /// Returns the name of the image asset associated with the current step.
    ///
    /// - Returns: A `String` corresponding to a local asset name.
    var imageName: String {
        switch stepNumber {
        case 1:  "dicomIcon"
        case 2:  "Sphere"
        case 3:  "Window"
        default: "unexpected"
        }
    }

    /// Returns the instructional text associated with the current step.
    ///
    /// - Returns: A `String` containing step-specific help content.
    var bodyText: String {
        switch stepNumber {
        case 1:  "Import the DICOM dataset from your local folder into the system."
        case 2:  "The system will generate a 3D model from the imported DICOM dataset."
        case 3:  "The system allows connection to a fluoroscope for real-time streaming of live 2D X-ray images."
        default: "Unexpected tutorial step."
        }
    }

    var body: some View {
        VStack {
            Text("Step \(stepNumber)")
                .font(.title)
            
            Spacer()
            
            Image(imageName)
                .resizable()
                .if(imageName == "dicomIcon") {
                    $0.offset(x: -11.5)
                }
                .if(imageName == "Window") {
                    $0.background {
                        Image(systemName: "app.connected.to.app.below.fill")
                            .resizable()
                            .frame(width: 45, height: 55)
                            .foregroundStyle(.green)
                            .offset(x: 15, y: 95)
                    }
                }
                .if(imageName == "Window") {
                    $0.frame(width: 230, height: 150)
                }
                .frame(width: 160, height: 160)

            Spacer()
            
            Text(bodyText)
                .frame(width: stepNumber == 3 ? 220 : 200)
                .multilineTextAlignment(.center)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding()
    }
}

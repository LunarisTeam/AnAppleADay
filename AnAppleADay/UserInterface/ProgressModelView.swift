//
//  ProgressModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 03/03/25.
//

import SwiftUI

/// A SwiftUI view that displays a progress indicator while generating a 3D model from a DICOM dataset.
///
/// `ProgressModelView` is shown during asynchronous model generation and transitions to the immersive space
/// once loading is complete. It uses a spinning `ProgressView` overlay on a placeholder image to represent activity.
struct ProgressModelView: View {
    
    /// Function used to change the current application mode.
    @Environment(\.setMode) private var setMode

    /// Access to the main application state model.
    @Environment(AppModel.self) private var appModel

    /// Tracks whether the model loading process has completed.
    @State private var loaded: Bool = false

    /// The DICOM dataset used to generate the 3D model.
    let dataSet: DicomDataSet

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // MARK: Loading Indicator
            Image("Sphere")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .overlay {
                    ProgressView()
                        .scaleEffect(1.5)
                }

            // MARK: Informational Text
            VStack(spacing: 8) {
                Text("Generating the 3D Model")
                    .font(.title)
                    .foregroundStyle(.white)

                Text("Please wait until your 3D Model is generated")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .onAppear {
            // Begin model loading when the view appears
            Task {
                try? await Task.sleep(for: .seconds(0.2)) // Small delay for smoother UI transition
                appModel.dataSetHolder = dataSet
                await appModel.entitiesLoaded {
                    loaded = true
                }
            }
        }
        .onChange(of: loaded) { _, newValue in
            // Switch to immersive space once loading is complete
            print("Switching to immersive space")
            Task { await setMode(.immersiveSpace, nil) }
        }
        .padding()
    }
}

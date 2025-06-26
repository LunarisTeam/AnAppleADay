//
//  GenerateModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 28/02/25.
//

import SwiftUI

/// A SwiftUI view that prompts the user to generate a 3D model from a previously imported DICOM dataset.
///
/// The view displays the dataset name, slice count, and a short description of the generation process.
/// It includes navigation controls to either go back to the import screen or proceed to model generation progress.
struct GenerateModelView: View {
    
    /// Environment value used to change the current application mode.
    @Environment(\.setMode) private var setMode

    /// Access to the application’s shared model.
    @Environment(AppModel.self) private var appModel

    /// The DICOM dataset that will be used to generate the 3D model.
    let dataSet: DicomDataSet

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // MARK: Title and Description
            VStack(spacing: 8) {
                Text("Generate the 3D Model")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Text("A 3D model will be generated from your imported\nDICOM dataset")
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 800)
            }

            Spacer()

            // MARK: DICOM Info and Preview
            VStack(spacing: 15) {
                Image("dicomIcon")
                    .resizable()
                    .offset(x: -10)
                    .scaledToFit()
                    .frame(width: 131, height: 131)

                VStack {
                    Text(dataSet.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)

                    Text("\(dataSet.sliceCount) slices")
                        .font(.headline)
                        .fontWeight(.light)
                }

                Spacer()
            }
        }

        // MARK: Back Button (bottom-left)
        .overlay(alignment: .bottomLeading) {
            Button("Back") {
                Task { await setMode(.importDicoms, dataSet) }
            }
            .buttonStyle(.borderless)
        }

        // MARK: Proceed Button (bottom-right)
        .overlay(alignment: .bottomTrailing) {
            Button("Proceed") {
                Task { await setMode(.progress, dataSet) }
            }
        }

        .frame(width: 600, height: 500)
        .padding()
    }
}

//
//  GenerateModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 28/02/25.
//

import SwiftUI

struct GenerateModelView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                Text("Generate your Model from Dicom")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text("""
The input from CT Scans and MRI is DICOM, once you imported \
the Model we have to generate the 3D Model, selecting just the arteries \
and the element that we need
""")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .frame(width: 530, height: 100, alignment: .center)
                .containerShape(Rectangle())
                
                Image("dicomIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white.opacity(0.8))
                
                NavigationLink(destination: ProgressModelView()) {
                    Text("Generate Model")
                        .fontWeight(.medium)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
            }
            .padding()
        }
    }
}

#Preview(windowStyle: .automatic) {
    GenerateModelView()
}

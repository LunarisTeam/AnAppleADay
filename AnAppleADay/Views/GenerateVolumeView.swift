//
//  GenerateVolumeView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 27/02/25.
//

import SwiftUI

struct GenerateVolumeView: View {
    var body: some View {
        
        ZStack {
           
            Color("BackgroundColor").ignoresSafeArea()
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 60, height: 60)))
                .opacity(0.4)
            
            VStack(spacing: 24) {
               
                Text("Generate your Model from Dicom")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text("""
The input from CT Scans and MRI is DICOM. Once imported, we can generate \
the 3D Model by selecting only the arteries and other elements we need.
""")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .frame(width: 530, height: 100, alignment: .center)
                .containerShape(Rectangle())
               
                Image("DicomIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white.opacity(0.8))
                
                Button(action: {
                    
                }) {
                    Text("Generate Model")
                        .fontWeight(.medium)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .cornerRadius(24)
                }
                .foregroundColor(.white)
            }
            .padding()
        }
    }
}

#Preview(windowStyle: .automatic) {
    GenerateVolumeView()
}

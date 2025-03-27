//
//  GenerateModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 28/02/25.
//

import SwiftUI

struct GenerateModelView: View {    
    
    @Environment(\.setMode) private var setMode
    
    let dataSet: DicomDataSet
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            VStack(spacing: 10) {
                
                Text("Generate the 3D Model")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text("A 3D model will be generated from your imported\nDICOM dataset")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 800)
            }
            
            VStack(spacing: 12) {
                Image("dicomIcon")
                    .resizable()
                    .offset(x: -10)
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(spacing: 2) {
                    Text(dataSet.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text("\(dataSet.sliceCount) slices")
                        .font(.headline)
                        .fontWeight(.light)
                }
            }
            
            Button("Generate Model") {
                Task { @MainActor in
                    await setMode(.model3DVolume, dataSet)
                }
            }
        }
        .padding()
    }
}



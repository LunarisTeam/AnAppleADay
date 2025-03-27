//
//  GenerateModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 28/02/25.
//

import SwiftUI

struct GenerateModelView: View {
    
    let dataSet: DicomDataSet
    
    @Environment(\.setMode) private var setMode
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                
                Text("3D Model Generation")
                    .font(.system(size: 45, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text("A 3D model will be generated from your imported\nDICOM dataset")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 800)
                    .padding()
                
                VStack(spacing: 4) {
                    Image("dicomIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(dataSet.name)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("\(dataSet.sliceCount) slices")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 12)
                
                Button {
                    Task {@MainActor in
                        await setMode(.needsImmersiveSpace, dataSet)
                    }
                } label: {
                    Text("Generate Model")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                }.padding(.top, 32)
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
    }
}



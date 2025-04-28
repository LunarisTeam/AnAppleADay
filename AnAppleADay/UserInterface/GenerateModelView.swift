//
//  GenerateModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 28/02/25.
//

import SwiftUI

struct GenerateModelView: View {    
    
    @Environment(\.setMode) private var setMode
    @Environment(AppModel.self) private var appModel
    
    let dataSet: DicomDataSet
    
    var body: some View {
        
        VStack(spacing: 40) {
            Spacer()
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
        .overlay(alignment: .bottomLeading) {
            Button("Back") {
                Task { await setMode(.importDicoms, dataSet) }
            }
            .buttonStyle(.borderless)
        }
        .overlay(alignment: .bottomTrailing) {
            Button("Proceed") {
                Task { await setMode(.progress, dataSet) }
            }
        }
        .frame(width: 600, height: 500)
        .padding()
    }
}



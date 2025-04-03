//
//  ProgressModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 03/03/25.
//

import SwiftUI

struct ProgressModelView: View {
    
    @Environment(\.setMode) private var setMode
    @Environment(AppModel.self) private var appModel
    
    @State private var loaded: Bool = false
    @State private var error: Error? = nil
    
    let dataSet: DicomDataSet
    
    var body: some View {
        
        if let error {
            ErrorView(error: error)
        } else {
            VStack(spacing: 40) {
                
                Spacer()
                
                Image("Sphere")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .overlay{
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                
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
            .task {
                appModel.dataSetHolder = dataSet
            }
            .onAppear {
                Task { await appModel.entitiesLoaded { loaded = true } }
            }
            .onChange(of: loaded) { _, newValue in
                print("Switching to immersive space")
                Task { await setMode(.immersiveSpace, nil) }
            }
            .padding()
        }
    }
}

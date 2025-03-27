//
//  ProgressModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 03/03/25.
//

import SwiftUI

struct ProgressModelView: View {
    
    @State private var navigateToVisualize = false
    @State private var currentStep: Int = 0
    
    private let totalSteps = 50
    private let updateInterval = 0.1

    var body: some View {
        
        ZStack {
            
            Color("backgroundColor")
                .opacity(0.3)
            
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
        }
        .glassBackgroundEffect()
        .padding()
        .frame(width: 676, height: 550)
    }
}

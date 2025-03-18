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
            
            VStack(spacing: 18) {
                
                Image("Sphere")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .overlay{
                        ProgressView()
                            .scaleEffect(2.0)
                    }
                
                Text("Generating the 3D Model")
                    .font(.system(size: 55, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Wait until your 3D Model is Generated")
                    .font(.system(size: 35, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .padding(32)
        }
        .frame(width: 900, height: 500)
        .glassBackgroundEffect()
    }
}

//
//  VisualizeModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 03/03/25.
//


import SwiftUI
import RealityKit

struct VisualizeModelView: View {
    var body: some View {

            
            VStack(spacing: 24) {
                Model3D(named: "Placeholder") { model in
                    model
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    
                    ProgressView("Loading 3D Model…")
                        .foregroundColor(.white)
                }
                .frame(width: 300, height: 300)
                
                Text("Albert Einstein's Heart")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
    }
}


#Preview(windowStyle: .automatic) {
    VisualizeModelView()
}

//
//  ProgressModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 03/03/25.
//

import SwiftUI

struct ProgressModelView: View {
    @State private var progress: CGFloat = 0.0
    @State private var navigateToVisualize = false
    @State private var currentStep: Int = 0
    let totalSteps = 50
    let updateInterval = 0.1

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image("Sphere")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .frame(width: 300)
                Text("Generating the 3D Model")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("Wait until your 3D Model is Generated")
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .onReceive(Timer.publish(every: updateInterval, on: .main, in: .common).autoconnect()) { _ in
                if currentStep < totalSteps {
                    currentStep += 1
                    progress = CGFloat(currentStep) / CGFloat(totalSteps)
                } else {
                    navigateToVisualize = true
                }
            }
            .navigationDestination(isPresented: $navigateToVisualize) {
                VisualizeModelView()
            }
        }
    }
}

#Preview {
    ProgressModelView()
}

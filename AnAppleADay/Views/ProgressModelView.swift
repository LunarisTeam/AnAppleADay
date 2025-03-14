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
            VStack(spacing: 18) {
                Image("Sphere")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .frame(width: 400)
                Text("Generating the 3D Model")
                    .font(.system(size: 55, weight: .bold))
                    .foregroundColor(.white)
                Text("Wait until your 3D Model is Generated")
                    .font(.system(size: 35, weight: .medium))
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
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    ProgressModelView()
}

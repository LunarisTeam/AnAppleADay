//
//  PopoverView.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 27/02/25.
//

import SwiftUI

struct PopoverView: View {
    
    @Binding var showInfo: Bool
    
    var body: some View {
        VStack(spacing: 35) {
            Text("How does it work?")
                .font(.title2)
            HStack(spacing: 20) {
                TutorialComponent(
                    imageName: "DICOM",
                    bodyText: "First, you import the DICOM files"
                )
                TutorialComponent(
                    imageName: "Sphere",
                    bodyText: "Then, generate the 3D Model"
                )
                TutorialComponent(
                    imageName: "Window",
                    bodyText: "You add the 2D X-ray imaging"
                )
            }
            Button {
                showInfo = false
            } label: {
                Text("Got it!")
            }
        }
        .frame(width: 800, height: 420)
        .padding()
    }
}

#Preview {
    PopoverView(showInfo: .constant(true))
}

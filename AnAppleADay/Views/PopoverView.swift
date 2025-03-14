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
            Text("Intrart structure")
                .font(.title2)
            HStack(spacing: 20) {
                TutorialComponent(
                    imageName: "dicomIcon",
                    bodyText: "First, import the DICOM Files"
                )
                TutorialComponent(
                    imageName: "Sphere",
                    bodyText: "Second, generate the 3D Model"
                )
                TutorialComponent(
                    imageName: "Window",
                    bodyText: "Third, connect the 2D X-ray Imaging"
                )
            }
            Button {
                showInfo = false
            } label: {
                Text("Proceed")
            }
        }
        .frame(width: 800, height: 420)
        .padding()
    }
}


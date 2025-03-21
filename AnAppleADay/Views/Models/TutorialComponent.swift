//
//  TutorialComponent.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 27/02/25.
//

import SwiftUI

struct TutorialComponent: View {
    
    let stepNumber: Int
    
    var imageName: String {
        switch stepNumber {
        case 1: return "dicomIcon"
        case 2: return "Sphere"
        case 3: return "Window"
        default: return "unexpected"
        }
    }
    
    var bodyText: String {
        switch stepNumber {
        case 1: return "Import the dicom dataset form your local folder into the system"
        case 2: return "The system will generate a 3D model from the imported DICOM dataset"
        case 3: return "The system allows connection to a fluoroscope for real-time streaming of live 2D X-ray images"
        default: return "unexpected"
        }
    }
    
    var body: some View {
        
        VStack {
            Text("Step \(stepNumber)").font(.title3)
            
            Spacer()
            
            Image(imageName).resizable()
                
            //This is a fix until design side doesn't provide the correct asset
                .if(imageName == "dicomIcon") {
                    $0.offset(x: -20)
                }
                .if(imageName == "Window") {
                    $0.background {
                        Image(systemName: "app.connected.to.app.below.fill").resizable()
                            .frame(width: 45, height: 55)
                            .foregroundStyle(.green)
                            .offset(x: 15, y: 95)
                    }
                }
                .if(imageName == "Window") {
                    $0.frame(width: 230, height: 150)
                }
                .frame(width: 200, height: 200)
            
            Spacer()
            
            Text(bodyText)
                .frame(width: stepNumber == 3 ? 220 : 200)
                .multilineTextAlignment(.center)
                .fontWeight(.medium)
            Spacer()
        }
        .padding()
    }
}

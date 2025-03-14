//
//  TutorialComponent.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 27/02/25.
//

import SwiftUI

struct TutorialComponent: View {
    
    let imageName: String
    let bodyText: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(.thinMaterial)
//                .foregroundStyle(Color("BackgroundColor"))
                .frame(width: 192, height: 213)
            
            VStack(spacing: 15) {
                Image(imageName).resizable()
                    .if(imageName == "Window") {
                        $0.frame(width: 130, height: 75)
                    }
                    .frame(width: 75, height: 75)
                Text(bodyText)
                    .frame(width: 140)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .frame(width: 192, height: 213)
    }
}

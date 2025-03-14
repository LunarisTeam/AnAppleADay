//
//  ErrorView.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 14/03/25.
//

import SwiftUI

struct ErrorView: View {
    
    let error: Error
    
    var body: some View {
        
        VStack {
            
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 100, maxHeight: 100)
                .foregroundStyle(.yellow)
            
            Spacer()
                .frame(height: 50)
            
            Text(error.localizedDescription)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(
            minWidth: 400, idealWidth: 400, maxWidth: 400,
            minHeight: 300,idealHeight: 300
        )
        .glassBackgroundEffect()
    }
}

//
//  PopoverView.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 27/02/25.
//

import SwiftUI

struct PopoverView: View {
    
    @Binding var showInfo: Bool
    @State private var stepCounter: Int = 1
    @State private var displayedStep: Int = 1
    
    var body: some View {
        VStack {
            TabView(selection: $stepCounter) {
                TutorialComponent(stepNumber: 1).tag(1)
                TutorialComponent(stepNumber: 2).tag(2)
                TutorialComponent(stepNumber: 3).tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showInfo = false
            } label: {
                Image(systemName: "xmark")
                    .imageScale(.large)
            }
            .buttonBorderShape(.circle)
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                if stepCounter < 3 {
                    withAnimation(.easeInOut(duration: 2)) {
                        stepCounter += 1
                    }
                }
            } label: {
                Text("Next")
            }
        }
        
        .overlay(alignment: .bottomLeading) {
            if stepCounter > 1 {
                Text("Previous")
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 8, trailing: 0))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 2)) {
                            stepCounter -= 1
                        }
                    }
            }
        }
        .frame(width: 600, height: 500)
        .padding()
    }
}

//
//  PopoverView.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 27/02/25.
//

import SwiftUI

struct InfoView: View {
    
    @Environment(OnboardingParameters.self) private var onboarding
    
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
            .opacity(onboarding.completed ? 1 : 0)
        }
        
        .overlay(alignment: .bottomTrailing) {
            Button {
                if stepCounter < 3 {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        stepCounter += 1
                    }
                    
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        onboarding.saveCompletionValue()
                        showInfo = false
                    }
                }
            } label: {
                Text(stepCounter == 3 ? "Proceed" : "Next")
            }
        }
        
        .overlay(alignment: .bottomLeading) {
            if stepCounter > 1 {
                Text("Previous")
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 8, trailing: 0))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            stepCounter -= 1
                        }
                    }
            }
        }
        .frame(width: 600, height: 500)
        .padding()
    }
}

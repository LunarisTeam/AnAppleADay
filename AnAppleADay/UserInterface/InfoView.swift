//
//  PopoverView.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 27/02/25.
//

import SwiftUI

/// A SwiftUI view that displays an onboarding tutorial using a multi-step tabbed interface.
///
/// `InfoView` shows three tutorial steps using `TutorialComponent`s inside a `TabView`.
/// It includes navigation buttons to move between steps and a dismiss button when onboarding is complete.
///
/// Once the user finishes all steps, onboarding completion is saved via `OnboardingParameters`.
struct InfoView: View {
    
    /// Environment object managing the user's onboarding state.
    @Environment(OnboardingParameters.self) private var onboarding
    
    /// Binding to control the visibility of the info popover.
    @Binding var showInfo: Bool
    
    /// Tracks the current step shown in the TabView (1 through 3).
    @State private var stepCounter: Int = 1
    
    /// Reserved for use if a distinction between actual step and displayed step is needed.
    @State private var displayedStep: Int = 1

    var body: some View {
        VStack {
            // MARK: Tutorial Pages
            TabView(selection: $stepCounter) {
                TutorialComponent(stepNumber: 1).tag(1)
                TutorialComponent(stepNumber: 2).tag(2)
                TutorialComponent(stepNumber: 3).tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }

        // MARK: Dismiss Button (top-right)
        .overlay(alignment: .topTrailing) {
            Button {
                showInfo = false
            } label: {
                Image(systemName: "xmark")
                    .imageScale(.large)
            }
            .buttonBorderShape(.circle)
            .opacity(onboarding.completed ? 1 : 0) // Only show dismiss if onboarding already completed
        }

        // MARK: Next / Proceed Button (bottom-right)
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

        // MARK: Previous Button (bottom-left)
        .overlay(alignment: .bottomLeading) {
            Button("Previous") {
                if stepCounter > 1 {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        stepCounter -= 1
                    }
                }
            }
            .buttonStyle(.borderless)
        }

        .frame(width: 600, height: 500)
        .padding()
    }
}

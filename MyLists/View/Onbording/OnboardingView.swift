//
//  OboardingPagedView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 11/10/2024.
//

import SwiftUI

struct OboardingPagedView: View {
    @State var completedOnboarding = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardigState: OnboardingState
    @State var buttonTitle = "Skip"
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Reusable Lists Onboarding")
                .font(.title)
                .foregroundStyle(Color.cyan)
            
            TabView {
                OnboardingPageView.welcomeTextPageView
                OnboardingPageView.toDoLists
                OnboardingPageView.addToDoListsButton
                OnboardingPageView.addToDoListsFields
                OnboardingPageView.addNewToDoItems
                OnboardingPageView.listItems
                OnboardingPageView.sortlistItems
                OnboardingPageView.listsCompletion
                OnboardingPageView.blueprints
                OnboardingPageView.blueprintAddListInstance
                OnboardingPageView.blueprintsInstanceList
                OnboardingPageView.entityUpdate
                OnboardingPageView.shareList
                    .onAppear {
                        buttonTitle = "Done"
                    }
            }
            .roundBordered(borderColor: .cyan, boderWidht: 1)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: UIScreen.main.bounds.height *  (UIDevice.iPhone ? 0.75 : 0.85))
            
            Button {
                onboardigState.didComplete()
            } label: {
                Text(buttonTitle)
                    .font(.title3)
            }
            
            Spacer()
            
        }
        .foregroundStyle(Color.cyan)
        .padding(.top, 16)
        .padding(.horizontal, 16)
    }
}

#Preview {
    OboardingPagedView()
}

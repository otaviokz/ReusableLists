//
//  AboutView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/03/2024.
//

import SwiftUI
import WebKit

struct AboutView: View {
    @State var isSheetPresented = false
    @EnvironmentObject private var onboardigState: OnboardingState
    @State private var showAddBlueprintFromListValueAlert = false
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Image.play.sizedToFitSquare(side: 21)
                        .padding(.top, 2)
                    Image("").sizedToFitSquare(side: 1.625)
                    Button { onboardigState.reset() }
                    label: { Text("Onboarding") }
                }
                .padding(.leading, 4)
                
                ShareLink(item: URL(string: "https://apps.apple.com/us/app/reusable-lists/id6478542301")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
                LabeledContent("Version", value: "2.3.1")
//                    .onLongPressGesture {
//                        SettingsManager
//                            .shared
//                            .flipShowAddBluetrpintFromList()
//                        
//                        showAddBlueprintFromListValueAlert = true
//                    }
                
                HTMLView(fileName: "PrivacyPolicy")
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .padding(.bottom, 12)
            }
            .scrollIndicators(.hidden)
            .foregroundStyle(Color.cyan)
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    OnboardingVideoView()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.automatic)
            }
//            .alert(isPresented: $showAddBlueprintFromListValueAlert) {
//                Alert(title: "Warning.", message: createBluePrintFromListEnabledMessage, dismiss: "OK")
//            }
            .navigationTitle("About")
        }
    }
}

private extension AboutView {
//    var createBluePrintFromListEnabledMessage: String {
//        "Create Blueprint from List: \(SettingsManager.shared.addBlueprintFromListEnabled ? "ENABLED" : "DISABLED")"
//    }
}

#Preview {
    AboutView()
}

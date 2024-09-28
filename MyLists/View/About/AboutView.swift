//
//  AboutView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/03/2024.
//

import SwiftUI
import WebKit

struct AboutView: View {
    @State var isSheetPresented = false
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Image.play.sizedToFit(width: 21, height: 21)
                        .padding(.top, 2)
                    Image("").sizedToFit(width: 2, height: 2)
                    Button { isSheetPresented.toggle() }
                    label: { Text("Show Onboarding") }
                }
                .padding(.leading, 4)
                
                ShareLink(item: URL(string: "https://apps.apple.com/us/app/reusable-lists/id6478542301")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
               

                HTMLView(fileName: localizedPrivecyPolicylFile)
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .cornerRadius(12)
                    .padding(.bottom, 8)
                
                LabeledContent("Version", value: "2.1.0")
            }
            .foregroundStyle(Color.cyan)
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    OnboardingView()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.automatic)
            }
        }
    }
    
    var localizedPrivecyPolicylFile: String {
        return switch Locale.current.language.languageCode?.identifier {
            case "es": "PrivacyPolicy_es"
            case "pt": "PrivacyPolicy_pt"
            default: "PrivacyPolicy"
        }
    }
}

struct HowToUseView: View, Hashable {
    var body: some View {
        Text("How to use")
    }
}

#Preview {
    AboutView()
}

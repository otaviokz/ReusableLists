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
                LabeledContent("Version", value: "1.1.0")
                
                Button(action: { isSheetPresented.toggle() }, label: {
                    Text("Show Onboarding")
                })
                
                ShareLink(item: URL(string: "https://apps.apple.com/us/app/reusable-lists/id6478542301")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
                VStack(alignment: .leading) {
                    Text("Privacy Policy")
                        .padding(.top, 8)
                    HTMLView(fileName: "PrivacyPolicy")
                        .frame(minHeight: UIScreen.main.bounds.height * 0.6, maxHeight: .infinity)
                        .cornerRadius(12)
                        .padding(.bottom, 8)
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    OnboardingView()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.automatic)
            }
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

//
//  AboutView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/03/2024.
//

import SwiftUI
import WebKit

struct AboutView: View {
    @EnvironmentObject private var onboardigState: OnboardingState
    @State private var page = WebPage()
    var body: some View {
        GeometryReader { proxy in
            Form {
                HStack {
                    Image.play.sizedToFitSquare(side: 21)
                        .padding(.top, 2)
                    Image.play.resizable().sizedToFitSquare(side: 1.625).opacity(0.0)
                    Button { onboardigState.reset() }
                    label: { Text("Onboarding") }
                }
                .padding(.leading, 4)
                
                ShareLink(item: URL(string: "https://apps.apple.com/us/app/reusable-lists/id6478542301")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                LabeledContent("Version", value: "2.8.1")

                WebView(page)
                    .frame(height: proxy.size.height * 0.7)
                    .padding(.bottom, 12)
                    .onAppear {
                        page.load(Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "html"))
                    }
            }
            .scrollIndicators(.hidden)
            .foregroundStyle(Color.cyan)
            .navigationTitle("About")
        }
    }
}

#Preview {
    AboutView()
}

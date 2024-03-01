//
//  OnboardingView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/03/2024.
//

import SwiftUI
import SwiftUI
import AVKit

struct OnboardingView: View {
    enum Field: Hashable {
        case avPlayer
    }
    
    @FocusState var focusState: Field?
    @State var videoPlayer = VideoPlayer(
        player: AVPlayer(url:  Bundle.main.url(forResource: "onboarding", withExtension: "mov")!)
    )
    
    var body: some View {
        VStack {
            VideoPlayer(player: AVPlayer(url:  Bundle.main.url(forResource: "onboarding", withExtension: "mov")!))
                .focused($focusState, equals: .avPlayer)
        }
        .frame(width: 296, height: 640)
        .onAppear {
            focusState = .avPlayer
        }
    }
}

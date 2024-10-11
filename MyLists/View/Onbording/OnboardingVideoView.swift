//
//  OnboardingView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/03/2024.
//

import SwiftUI
import AVKit

struct OnboardingVideoView: View {
    @State var videoPlayer = AVPlayer(url: Bundle.main.url(forResource: "howto", withExtension: "mov")!)
    
    var body: some View {
        VStack {
            VideoPlayer(player: videoPlayer)
        }
        .frame(width: 296, height: 640)
        .onAppear {
            videoPlayer.play()
        }
    }
}

#Preview {
    OnboardingVideoView()
}

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

//
//  VideoPlayerView.swift
//  AnAppleADay
//
//  Created by Eduardo Gonzalez Melgoza on 28/03/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    private let videoURL = URL(string: "http://10.20.50.9:8000/xrayVideo.m3u8")!
    @State private var player = AVPlayer()
    
    var body: some View {
        VideoPlayer(player: player)
            .frame(width: 600, height: 400)
            .onAppear {
                player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                player.play()
            }
    }
}

#Preview {
    VideoPlayerView()
}

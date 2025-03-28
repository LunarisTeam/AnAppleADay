//
//  VideoPlayerView.swift
//  AnAppleADay
//
//  Created by Eduardo Gonzalez Melgoza on 28/03/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    
    @Environment(AppModel.self) private var appModel
    
    @State private var player = AVPlayer()
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if let videoURL = URL(string: "http://\(appModel.address):\(appModel.port)/\(appModel.fileName)"){
                    player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                    player.play()
                }else{
                    print("error video")
                }
               
            }
    }
}

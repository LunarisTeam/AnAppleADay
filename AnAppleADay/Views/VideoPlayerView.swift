//
//  VideoPlayerView.swift
//  AnAppleADay
//
//  Created by Eduardo Gonzalez Melgoza on 28/03/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    
    @Environment(\.setMode) private var setMode
    @Environment(AppModelServer.self) private var appModelServer
    @Environment(AppModel.self) private var appModel
    
    @State private var player = AVPlayer()
    @State private var degrees: Double = 0

    var body: some View {
        VStack{
            VideoPlayer(player: player)
                .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
                .persistentSystemOverlays(appModel.hideBar ? .hidden : .visible)
                .onAppear {
                    if let videoURL = URL(string: "http://\(appModelServer.address):\(appModelServer.port)/\(appModelServer.fileName)"){
                        player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                        player.play()
                        appModelServer.isConnected = true
                    }else{
                        print("error video")
                    }
                    
                    Task { await setMode(.immersiveSpace, nil) }
                }

                Slider(value: $degrees, in: -180...180)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 30)
            
        }
    }
}

//
//  ContentView.swift
//  VideoApp
//
//  Created by Rezaul Islam on 6/5/24.
//

import SwiftUI
import AVKit

class PlayerObserver: NSObject {
    @Binding var isPlaying: Bool
    
    init(isPlaying: Binding<Bool>) {
        _isPlaying = isPlaying
    }
    
    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(AVPlayer.timeControlStatus) else { return }
        if let newStatusRawValue = change?[.newKey] as? Int, let newStatus = AVPlayer.TimeControlStatus(rawValue: newStatusRawValue) {
            if newStatus == .playing {
                isPlaying = true
                print("Video is playing")
            } else {
                isPlaying = false
                print("Video is paused")
            }
        }
    }
}

struct VideoPlayerView: View {
    @State private var isPlaying: Bool = true
    @State private var player = AVPlayer(url: URL(string: "https://embed-ssl.wistia.com/deliveries/cc8402e8c16cc8f36d3f63bd29eb82f99f4b5f88/accudvh5jy.mp4")!)
     @State private var playerTimeControlStatus: AVPlayer.TimeControlStatus = .paused
    @State var playerObserver: PlayerObserver!
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                VideoPlayer(player: player)
                    .frame(width: geometry.size.width, height: calculateHeight(player: player, geometry: geometry))
                
                
                Button(action: {
                    
                    if isPlaying {
                        player.pause()
                        isPlaying = false
                    } else {
                        player.play()
                        isPlaying = true
                    }
                    
                }, label: {
                    Image(systemName: isPlaying ? "pause.circle" :"play.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                })
            }
        }
        .background(.green.opacity(0.1))
        .edgesIgnoringSafeArea(.horizontal)
        
        .onAppear {
            player.play()
            player.isMuted = true
            // Initialize player observer
            playerObserver = PlayerObserver(isPlaying: $isPlaying)
            // Add observer for AVPlayer's timeControlStatus
            player.addObserver(playerObserver, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.old, .new], context: nil)
        }
        .onDisappear {
            // Remove observer when the view disappears
            player.removeObserver(playerObserver, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        }
        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        
    }
    
    func calculateHeight(player: AVPlayer, geometry: GeometryProxy) -> CGFloat {
        guard let asset = player.currentItem?.asset as? AVURLAsset else { return 0 }
        let videoTrack = asset.tracks(withMediaType: .video).first
        let videoSize = videoTrack?.naturalSize.applying(videoTrack!.preferredTransform)
        
        if let width = videoSize?.width, let height = videoSize?.height {
            let aspectRatio = height / width
            return geometry.size.width * aspectRatio
        }
        return 0
    }
}

#Preview {
    VideoPlayerView()
}

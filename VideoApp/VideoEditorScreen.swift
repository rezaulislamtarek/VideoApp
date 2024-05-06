//
//  VideoEditorScreen.swift
//  VideoApp
//
//  Created by Rezaul Islam on 6/5/24.
//

import SwiftUI
import AVFoundation
import MobileCoreServices
import _AVKit_SwiftUI

struct VideoEditorScreen: View {
    @Binding var showVideoEditor : Bool
    @State private var videoURL: URL?
    @State private var trimmedVideoURL: URL?
    @State private var trimPosition: Double = 0
    @State private var isTrimming = false
    @State private var showImagePicker = false
    var body: some View {
        VStack{
            toolBar
            if videoURL == nil{
                videoPlaceHolderSection
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
            }else{
                if trimmedVideoURL == nil {
                    VideoPlayer(player: AVPlayer(url: videoURL!))
                        .frame(height: 250)
                        .padding()
                        .cornerRadius(25)
                }
            }
            
            if trimmedVideoURL == nil{
                if videoURL != nil{
                    HStack {
                        Text("Trim Video:")
                        Slider(value: $trimPosition, in: 0...maxTrimPosition(), step: 0.1)
                            .disabled(isTrimming)
                        Text("\(trimPosition, specifier: "%.1f") s")
                    }
                    .padding()
                }
            }
            
            if isTrimming {
                ProgressView("Trimming...")
            }
            
            if let trimmedVideoURL = trimmedVideoURL {
                VideoPlayer(player: AVPlayer(url: trimmedVideoURL))
                
                    .frame(height: 250)
                    .padding()
                    .cornerRadius(25)
            }
            
            if videoURL != nil{
                Button(action: {
                    trimVideo()
                }) {
                    Text("Trim Video")
                }
                .disabled(isTrimming)
            }
            
            Spacer()
            
        }
        .sheet(isPresented : $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary, mediaTypes: [kUTTypeMovie as String], onSelected: { url in
                self.videoURL = url
                print("Video Url: \(url)")
            })
        }
    }
}

extension VideoEditorScreen{
    func loadVideo() {
            // Load your video URL here
            // For example:
            self.videoURL = Bundle.main.url(forResource: "exampleVideo", withExtension: "mp4")
        }
        
        func trimVideo() {
            guard let videoURL = videoURL else { return }
            
            let asset = AVAsset(url: videoURL)
            let duration = CMTime(seconds: 7, preferredTimescale: 600)
            let startTime = CMTime(seconds: trimPosition, preferredTimescale: 600)
            
            let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(Date().description+"trimed.mp4")
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.timeRange = CMTimeRange(start: startTime, duration: duration)
            
            isTrimming = true
            
            exportSession.exportAsynchronously {
                DispatchQueue.main.async {
                    self.isTrimming = false
                    switch exportSession.status {
                    case .completed:
                        self.trimmedVideoURL = outputURL
                    case .failed, .cancelled:
                        print("Trimming failed")
                    default:
                        break
                    }
                }
            }
        }
        
    func maxTrimPosition() -> Double {
        guard let _ = videoURL else {
            return 7
        }
        let asset = AVAsset(url: videoURL!)
        let duration = CMTimeGetSeconds(asset.duration)
        return max(0, duration - 7)
    }
}

extension VideoEditorScreen{
    
    private var videoPlaceHolderSection : some View{
        RoundedRectangle(cornerRadius: 25.0, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
            .fill(.green.opacity(0.1))
            .frame(height: 250)
            .padding()
            .overlay {
                VStack{
                    Image(systemName: "plus")
                        .resizable()
                        .foregroundColor(.green.opacity(0.8))
                        .frame(width: 50, height: 50)
                    Text("Tap to add video here.")
                }
            }
    }
    
    
    private var toolBar : some View{
        HStack{
            Button(action: {
                withAnimation {
                    showVideoEditor.toggle()
                }
            }, label: {
                Image(systemName: "chevron.left")
            })
            Spacer()
            Text("Editor")
            Spacer()
        }
        .padding()
    }
}

#Preview {
    VideoEditorScreen(showVideoEditor: .constant(false))
}

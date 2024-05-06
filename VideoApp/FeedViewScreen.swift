//
//  SwiftUIView.swift
//  VideoApp
//
//  Created by Rezaul Islam on 6/5/24.
//

import SwiftUI

struct FeedViewScreen: View {
    @State var videoEditor : Bool = false
    var body: some View {
        VStack{
            if !videoEditor{
                HStack{
                    Image("reza_photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.green)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    
                    Text("Rezaul Islam")
                    Spacer()
                    Image(systemName: "ellipsis")
                }
                .padding(.horizontal)
                VideoPlayerView()
                Spacer()
                Button("Upload a video") {
                    withAnimation {
                        videoEditor.toggle()
                    }
                }
                .buttonStyle(.bordered)
            }
            else{
                VideoEditorScreen(showVideoEditor: $videoEditor)
            }
        }
    }
}

#Preview {
    FeedViewScreen()
}

//
//  FinalPreviewView.swift
//  Custom Video Recorder
//
//  Created by Phat Vuong Vinh on 9/10/24.
//

import SwiftUI
import AVKit
import Photos

struct FinalPreviewView: View {
    
    
    var url: URL
    
    @Binding var showPreview: Bool

    
    var body: some View {
        
        let player = AVPlayer(url: url)
        GeometryReader { geometry in
            
            let size = geometry.size
            
            VideoPlayer(player: player)
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .onAppear {
                    player.play()
                }
            // MARK: back button
                .overlay(alignment: .topLeading) {
                    
                    Button(action: {
                        showPreview.toggle()
                    }) {
                        Label {
                            Text("Back")
                        } icon: {
                            Image(systemName: "chevron.left")
                        }
                        .foregroundStyle(.white)
                    }
                    .padding(.leading)
                    .padding(.top,22)
                }
                .overlay(alignment: .topTrailing) {

                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up.fill")
                            .padding(.trailing)
                            .padding(.top,22)
                    }
                    .foregroundStyle(.white)
                   

                }
                
        }
        
    }
    


}


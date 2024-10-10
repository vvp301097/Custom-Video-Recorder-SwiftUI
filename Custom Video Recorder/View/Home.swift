//
//  Home.swift
//  Custom Video Recorder
//
//  Created by Phat Vuong Vinh on 8/10/24.
//

import SwiftUI

struct Home: View {
    
    @StateObject var cameraViewModel: CameraViewModel = CameraViewModel()
        
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: Camera View
            CameraView()
                .environmentObject(cameraViewModel)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.top, 10)
                .padding(.bottom, 30)
            
            // MARK: Controls
            ZStack {
                
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if cameraViewModel.isRecording {
                                
                                cameraViewModel.stopRecording()
                            } else {
                                cameraViewModel.startRecording()
                            }
                        }
                        
                    } label: {
                        
                        ZStack{
                            ZStack {
                                if cameraViewModel.isRecording {
                                    Rectangle()
                                        .fill(Color.red)
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(8)
                                } else {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 60, height: 60)
                                    
                                }
                                
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .frame(width: 65, height: 65)
                            }
                            
                        }
                        .frame(height: 65)
                        
                    }
                    
                    Button {
                        if let _ = cameraViewModel.previewURL {
                            cameraViewModel.showPreview.toggle()
                        }
                    } label: {
                        
                        Group {
                            if cameraViewModel.previewURL == nil && !cameraViewModel.recordedURLs.isEmpty {
                                // Merging Videos
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Label {
                                    Image(systemName: "chevron.right")
                                        .font(.callout)
                                } icon: {
                                    Text("Preview")
                                }
                                .foregroundStyle(.black)
                            }
                        }
                        
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(.white)
                        }
                        

                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing)
                    .opacity((cameraViewModel.previewURL == nil && cameraViewModel.recordedURLs.isEmpty) || cameraViewModel.isRecording ? 0 : 1)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.top, 10)
            .padding(.bottom, 30)
            
            if !cameraViewModel.isRecording && !cameraViewModel.recordedURLs.isEmpty {
                Button {
                    cameraViewModel.clear()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding()
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            


        }
        .overlay(content: {
            if let url = cameraViewModel.previewURL, cameraViewModel.showPreview {
                FinalPreviewView(url: url, showPreview: $cameraViewModel.showPreview)
                    .transition(.move(edge: .trailing))
            }
        })
        .animation(.easeInOut, value: cameraViewModel.showPreview)

        .preferredColorScheme(.dark)
    }
}

#Preview {
    Home()
}

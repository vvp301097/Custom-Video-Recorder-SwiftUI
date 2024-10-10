//
//  CameraView.swift
//  Custom Video Recorder
//
//  Created by Phat Vuong Vinh on 8/10/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @EnvironmentObject var cameraViewModel: CameraViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            let size = geometry.size
            
            CameraPreview(size: size)
                .environmentObject(cameraViewModel)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.black.opacity(0.25))
                
                Rectangle()
                    .fill(.blue)
                    .frame(width: size.width * (cameraViewModel.recordedDuration / cameraViewModel.maxDuration))
            }
            .frame(height: 8)
            .frame(maxHeight: .infinity, alignment: .top)
        }
       
        .onAppear {
            cameraViewModel.checkPermission()
            DispatchQueue.global(qos: .background).async {
                self.cameraViewModel.session.startRunning()
            }
            
        }
        .alert(isPresented: $cameraViewModel.alert) {
            Alert(title: Text("Permission Denied"), message: Text("Please allow access to camera or microphone"), dismissButton: .default(Text("OK")))
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect(), perform: { _ in
            if cameraViewModel.isRecording && cameraViewModel.recordedDuration <= cameraViewModel.maxDuration {
                cameraViewModel.recordedDuration += 0.01
            }
            
            if cameraViewModel.isRecording && cameraViewModel.recordedDuration >= cameraViewModel.maxDuration  {
                cameraViewModel.stopRecording()
            }
        })
    }
}



// Setting view for Preview

struct CameraPreview: UIViewRepresentable {
    
    @EnvironmentObject var camera: CameraViewModel
    
    var size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        previewLayer.frame.size = size
        
        
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}


#Preview {
    CameraView()
}

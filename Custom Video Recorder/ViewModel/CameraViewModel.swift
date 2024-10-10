//
//  CameraViewModel.swift
//  Custom Video Recorder
//
//  Created by Phat Vuong Vinh on 8/10/24.
//

import AVFoundation


class CameraViewModel: NSObject, ObservableObject {
    
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCaptureMovieFileOutput()
    
    // MARK: Video Recorder Properties
    @Published var isRecording: Bool = false
    @Published var recordedURLs: [URL] = []
    @Published var previewURL: URL?
    @Published var showPreview: Bool = false
    
    // Top progress bar
    @Published var recordedDuration: CGFloat = 0
    @Published var maxDuration: CGFloat = 20
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setup()
                }
            }
        case .denied:
            self.alert.toggle()
        default:
            return
        }
    }
    
    func setup() {
        // setting up the Camera
        do {
            
            // setting configs...
            self.session.beginConfiguration()
            
            // Camera
            let cameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice!)
            
            // Audio
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            // checking and adding to session ...
            if self.session.canAddInput(videoInput) && self.session.canAddInput(audioInput)  {
                self.session.addInput(videoInput)
                self.session.addInput(audioInput)
            }
            
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startRecording() {
        
        // MARK: Temporary URL for recording Video
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(Date()).mov")
        
        output.startRecording(to: tempURL, recordingDelegate: self)
        
        isRecording = true
    }
    
    func stopRecording() {
        
        output.stopRecording()
        isRecording = false
        
    }
    
    func clear() {
        recordedDuration = 0
        previewURL = nil
        recordedURLs.removeAll()
    }
}

extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        
        if let error {
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        // Created successfully
        
        print(outputFileURL)
        
        self.recordedURLs.append(outputFileURL)
        
        if self.recordedURLs.count == 1 {
            self.previewURL = self.recordedURLs.first
            return
        }
        
        // CONVERTING URL TO AVASSETS
        
        let assets = recordedURLs.compactMap({ AVURLAsset(url: $0) })
        
        self.previewURL = nil
        // merge videos
        
        mergeVideos(assets: assets) { exporter in
            exporter.exportAsynchronously {
                if exporter.status == .failed {
                    
                    print(exporter.error!.localizedDescription)
                } else {
                    if let finalURL = exporter.outputURL {
                        print("Merged video: \(finalURL)")
                        
                        DispatchQueue.main.async {
                            self.previewURL = finalURL
                        }
                    }
                }
                
                
            }
        }
    }
    
    
    func mergeVideos(assets: [AVURLAsset], completion: @escaping (_ exporter: AVAssetExportSession)->() ) {
        let composition = AVMutableComposition()
        var lastTime: CMTime = .zero
        
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        
        for asset in assets {
            // Linking Audio and Video
            do {
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, end: asset.duration), of: asset.tracks(withMediaType: .video)[0], at: lastTime)
                if !asset.tracks(withMediaType: .audio).isEmpty {
                    try audioTrack.insertTimeRange(CMTimeRange(start: .zero, end: asset.duration), of: asset.tracks(withMediaType: .audio)[0], at: lastTime)
                }
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            
            lastTime = CMTimeAdd(lastTime, asset.duration)
        }
        
        // MARK: Temp Output URL
        let tempOutputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("merged-video-\(Date()).mp4")
        
        
        // Make Video to original transform when it is retated
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // MARK: Transform
        
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: .pi / 2)
        transform = transform.translatedBy(x: 0, y: -videoTrack.naturalSize.height)
        layerInstruction.setTransform(transform, at: .zero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        
        instruction.timeRange = CMTimeRange(start: .zero, end: lastTime)
        instruction.layerInstructions = [layerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else { return }
        
        exporter.outputFileType = .mp4
        exporter.outputURL = tempOutputURL
        exporter.videoComposition = videoComposition
        completion(exporter)
    }
    
}

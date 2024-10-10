# Custom Video Recorder - Custom Camera - SwiftUI - AVFoundation - Merging Multiple Videos

## Overview
This project is a custom-built video recording app using **SwiftUI** and **AVFoundation**. It provides a custom camera interface that allows users to record multiple video segments and merge them into a single video. 

### Key Features:
- Custom camera interface built in SwiftUI
- Utilizes **AVFoundation** for recording video
- Merge multiple recorded video clips into one
- Preview recorded videos before saving
- Sharing video via URL

## Demo Video
[![Watch the Demo](https://i.ytimg.com/vi/SrP59oyd7pI/oar2.jpg?sqp=-oaymwEdCM0CENAFSFWQAgHyq4qpAwwIARUAAIhCcAHAAQY=&rs=AOn4CLAtud0gd-D0vGFAynNqmtNc67curw)](https://youtube.com/shorts/SrP59oyd7pI)
Click the image above to watch the demo video.

## How it Works
This project is built around **AVFoundation** to handle video recording and merging. The custom camera interface is designed with **SwiftUI**, while the actual video processing (recording, merging) is handled using **AVCaptureSession** and **AVAssetExportSession**.

## Merging Multiple Videos
The app uses **AVMutableComposition** to merge multiple video segments into one continuous video. Each recorded clip is added as a track to the composition, and then exported using **AVAssetExportSession**.

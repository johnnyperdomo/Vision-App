# Vision-App
iOS app that identifies objects using coreML written in Swift4

## Preview 
<img src="https://github.com/johnnyperdomo/Vision-App/blob/master/Vision-App/Videos/ezgif.com-video-to-gif.gif" width="275" height="450" /> 



**Built with**
- Ios 11
- Xcode 9 

## Requirements
[SquezeNet.mlmodel](https://github.com/DeepScale/SqueezeNet) Detects the dominant objects present in an image from a set of 1000 categories such as trees, animals, food, vehicles, person, etc.

```swift
import AVFoundation //Work with audiovisual assets, control device cameras, process audio, and configure system audio interactions.
import CoreML //handles Machine-learning
import Vision //handles Face-Object recognition
```

## Features:
- **Access Camera**
  ```swift
  var captureSession: AVCaptureSession!
  ...
  captureSession = AVCaptureSession()
  ```
- **Capture Photo and Save it in small preview**
  ```swift
  var cameraOutput: AVCapturePhotoOutput!
  ...
  cameraOutput.capturePhoto
  ```
- **Control camera Flash**
  ```swift
  let flashControl = AVCapturePhotoSettings() 
  flashControl.flashMode = .on
  ```
- **Tries to Identify Object we take a Picture of**
  ```swift
  (request: VNRequest)
  results = request.results as? [VNClassificationObservation] //"VNClassificationObservation" observes what was in the image
  ```
- **Shows accuracy of Object identification**
  ```swift
  classification.confidence
  ```
- **App reads Results outloud using AVSpeechSynthesizer**
  ```swift
  var speechSynthesizer = AVSpeechSynthesizer() 
  ```
  
### Credits
Devslopes CoreML Tuts

## License
Standard MIT [License](https://github.com/johnnyperdomo/Vision-App/blob/master/LICENSE)

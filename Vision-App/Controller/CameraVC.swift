//
//  ViewController.swift
//  Vision-App
//
//  Created by Johnny Perdomo on 4/26/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import AVFoundation //lets us access camera, can process audio...
import CoreML //handles overall machine learning stuff
import Vision //handles things like face/object recognition

enum FlashState { //state of the flashlight
    case off
    case on
}

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession: AVCaptureSession! //control our real time capture of the camera
    var cameraOutput: AVCapturePhotoOutput! //capture a still image from an AVCapture session
    var previewLayer: AVCaptureVideoPreviewLayer! //added to backgroundView to show the camera
    
    var photoData: Data?
    
    var flashControlState: FlashState = .off //off by default
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureImageView: RoundedShadowImageView!
    @IBOutlet weak var flashBtn: RoundedShadowButton!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var RoundedLblView: RoundedShadowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds //puts a camera view into our background view , cand conforms it to the bounds of the view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView)) //set up tap gesture recognizer
        tap.numberOfTapsRequired = 1 //needs only 1 tap to take photo
        
        captureSession = AVCaptureSession() //instatiate
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080 //captures the fullsize of screen in 1080p
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video) //lets us utilize default camera which is the backside of the phone;.video capturesthe full screen of the image, unlike photo which captures just a small portion of it
        
        do { //input camera to use it and allows it to record
            let input = try AVCaptureDeviceInput(device: backCamera!)
            
            if captureSession.canAddInput(input) == true { //checks if we can add an input(i.e camera view)
                captureSession.addInput(input) //if yes, add the input.
            }
            
            cameraOutput = AVCapturePhotoOutput() //instantiate
            
            if captureSession.canAddOutput(cameraOutput) == true { //to determine what we do with what the camera sees, do we turn it into photo,video,...etc?
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!) //instantiate, we need a captureSession
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect //forces it to preserve aspect ratio
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait //to determine what our capture session is coming in as, rotated phone, or portrait mode
                
                cameraView.layer.addSublayer(previewLayer!) //add the preview layer to the cameraView
                cameraView.addGestureRecognizer(tap) //add tap gesture into our view
                captureSession.startRunning() //itll start showing us what the camera sees
            }
        } catch {
            debugPrint(error)
        }
    }
    
    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings() //photo settings with what happens when we request a picture
        
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat // sets it up for our photo to be previewSized, doesn't need to be full 1920 x 1080 size; thumbnail size
        
        if flashControlState == .off { //if control state is off
            settings.flashMode = .off //photosettings has a flash mode we can turn on or off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self) //it captures the image with settings and its own delegate

    }

    func resultsMethod(request: VNRequest, error: Error?) { //function to control what happens when we receive the results we requested from the model
        guard let results = request.results as? [VNClassificationObservation] else { return } //place to store results that are returned; "VNClassificationObservation" observes what was in the image
        
        for classification in results { //loop through the classifications and pick the most accurate one to our image
            print(classification.identifier)
            if classification.confidence < 0.1 { //if the confidence is less than %50
                self.identificationLbl.text = "I'm not sure what this is. Please try again." //if not confident
                self.confidenceLbl.text = "" //doesn't show anything
                break //so it leaves the for loop
            } else { //if confidence is more than 50%
                self.identificationLbl.text = classification.identifier //identifier is what it thinks it saw
                self.confidenceLbl.text = "CONFIDENCE: \(Int(classification.confidence * 100))%" //.confidence shows the percentage; Int for the number to be a whole number
                break
            }
        }
    }
    
    
    
    //delegate avcapture conforms to
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error { //if error
            debugPrint(error)
        } else { //if everything works smoothly
            photoData = photo.fileDataRepresentation() //returns data, getting photo data and were saving it in 'photoData' variable
            
            do { //throws errors
                let model = try VNCoreMLModel(for: SqueezeNet().model) //we pass in an ml model: 'squeezenet', and pull out the model with .model; passing it through vision //model is like the brain
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod) //we need to make a request...kind of like a mental thought...we dont need to input parameters, it already has a request and error
                let handler = VNImageRequestHandler(data: photoData!) //handles image requests; it handles our photoData we pass into it
                try handler.perform([request]) //handler performs the request, compares 'photoData' to request, and gives us back data
            } catch {
                debugPrint(error)
            }
            
            
            let image = UIImage(data: photoData!) //create an image using the photoData
            self.captureImageView.image = image //convert data we get from our camera, and we pass it into our camera view
        }
    }
    
    @IBAction func flashBtnPressed(_ sender: Any) { //when flash btn pressed
        switch flashControlState { //to switch between states
        case .off:
            flashBtn.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
        case .on:
            flashBtn.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
    }
    
}


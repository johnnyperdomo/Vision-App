//
//  ViewController.swift
//  Vision-App
//
//  Created by Johnny Perdomo on 4/26/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import AVFoundation //lets us access camera, can process audio...

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession: AVCaptureSession! //control our real time capture of the camera
    var cameraOutput: AVCapturePhotoOutput! //capture a still image from an AVCapture session
    var previewLayer: AVCaptureVideoPreviewLayer! //added to backgroundView to show the camera
    
    var photoData: Data?
    
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
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first! //'first' is just the general picture type, basic ios photo...can use live photos...etc
        let previewformat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160] //dictionary
        
        settings.previewPhotoFormat = previewformat //pass in our preview format; sets it up for our photo to be previewSized, doesn't need to be full 1920 x 1080 size
        
        cameraOutput.capturePhoto(with: settings, delegate: self) //it captures the image with settings and its own delegate
        
        
    }
    
    //delegate avcapture conforms to
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error { //if error
            debugPrint(error)
        } else { //if everything works smoothly
            photoData = photo.fileDataRepresentation() //returns data, getting photo data and were saving it in 'photoData' variable
            
            let image = UIImage(data: photoData!) //create an image using the photoData
            self.captureImageView.image = image //convert data we get from our camera, and we pass it into our camera view
        }
    }
    
    
    
    
    
    
    
    
}


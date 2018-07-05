//
//  ViewController.swift
//  yolo-object-tracking
//
//  Created by Mikael Von Holst on 2017-12-19.
//  Copyright © 2017 Mikael Von Holst. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation
import Accelerate


class SSDViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var frameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    
    let semaphore = DispatchSemaphore(value: 1)
    var lastExecution = Date()
    var screenHeight: Double?
    var screenWidth: Double?


    let objectPredictor = FritzVisionObjectModel()

    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()

    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        // session.sessionPreset = AVCaptureSession.Preset.
        
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }
        session.addInput(input)
        return session
    }()

    let numBoxes = 100
    var boundingBoxes: [BoundingBoxOutline] = []
    let multiClass = true
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.frameLabel.textAlignment = .left
//        screenWidth = Double(view.frame.width)
//        screenHeight = Double(view.frame.height)
//        var image = UIImage(named: "000000000139_resized.png")
//        imageView.image = image
//        setupBoxes()
//        runPrediction(image: image!)
//    }
//    func setupBoxes() {
//        // Create shape layers for the bounding boxes.
//        for _ in 0..<numBoxes {
//            let box = BoundingBoxOutline()
//            box.addToLayer(imageView.layer)
//            self.boundingBoxes.append(box)
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        self.cameraView?.bringSubview(toFront: self.frameLabel)
        self.frameLabel.textAlignment = .left
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()

        screenWidth = Double(view.frame.width)
        screenHeight = Double(view.frame.height)
        setupBoxes()
    }

     func setupBoxes() {
         // Create shape layers for the bounding boxes.
         for _ in 0..<numBoxes {
             let box = BoundingBoxOutline()
             box.addToLayer(cameraView.layer)
             self.boundingBoxes.append(box)
          }
     }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraLayer.frame = cameraView.layer.bounds
    }
    

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func drawBoxes(predictions: [FritzVisionObject]) {
        for (index, prediction) in predictions.enumerated() {
            print("\(prediction.label.label): \(prediction.label.confidence)")
            let textColor: UIColor
            let textLabel = String(format: "%.2f - %@", prediction.label.confidence, prediction.label.label)
            textColor = UIColor.black
            var box = prediction.boundingBox
            // box = BoundingBox.oneByOneBox()
            let frame = view.frame
            // let frame = imageView.frame
            print(frame)

//            let rect = box.toCGRect(imgWidth: Double(frame.width), imgHeight: Double(frame.height), xOffset: Double(frame.minX), yOffset: Double(frame.minY))
            let yOffset = (Double(frame.height) - Double(frame.width)) / 2.0
            let rect = box.toCGRect(imgWidth: Double(frame.width), imgHeight: Double(frame.width), xOffset: Double(0.0), yOffset: yOffset)
            self.boundingBoxes[index].show(frame: rect,
                                           label: textLabel,
                                           color: UIColor.red, textColor: textColor)
        }

        for index in predictions.count..<self.numBoxes {
            self.boundingBoxes[index].hide()
        }
    }

    func runPrediction(image: UIImage) {
        let requestOptions:[VNImageOption : Any] = [:]
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(EXIFOrientation.rightTop.rawValue))
        let pixelBuffer = image.pixelBuffer(width: 300, height: 300)!
        objectPredictor.predict(pixelBuffer, orientation: orientation!, options: requestOptions) { (results, error) in
            if let error = error {
                print(error)
                return
            }
            if let results = results {
                DispatchQueue.main.async {
                    self.drawBoxes(predictions: results)
                }
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var requestOptions:[VNImageOption : Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(EXIFOrientation.rightTop.rawValue))

        objectPredictor.predict(pixelBuffer, orientation: orientation!, options: requestOptions) { (results, error) in
            if let error = error {
                print(error)
                return
            }

            if let results = results {
                DispatchQueue.main.async {
                    self.drawBoxes(predictions: results)
                }
            }
        }
    }

    func sigmoid(_ val:Double) -> Double {
        return 1.0/(1.0 + exp(-val))
    }

    enum EXIFOrientation : Int32 {
        case topLeft = 1
        case topRight
        case bottomRight
        case bottomLeft
        case leftTop
        case rightTop
        case rightBottom
        case leftBottom

        var isReflect:Bool {
            switch self {
            case .topLeft,.bottomRight,.rightTop,.leftBottom: return false
            default: return true
            }
        }
    }

    func compensatingEXIFOrientation(deviceOrientation:UIDeviceOrientation) -> EXIFOrientation
    {
        switch (deviceOrientation) {
        case (.landscapeRight): return .bottomRight
        case (.landscapeLeft): return .topLeft
        case (.portrait): return .rightTop
        case (.portraitUpsideDown): return .leftBottom

        case (.faceUp): return .rightTop
        case (.faceDown): return .rightTop
        case (_): fallthrough
        default:
            NSLog("Called in unrecognized orientation")
            return .rightTop
        }
    }
}


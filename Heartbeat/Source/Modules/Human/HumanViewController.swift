//
//  HumanViewController.swift
//  Heartbeat
//
//  Created by Andrew Barba on 1/6/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage
import Fritz
import Firebase
import Vision.VNRequest

class HumanViewController: UIViewController {
    
    lazy var vision = Vision.vision()

    @IBOutlet weak var resultView: UIView! {
        didSet { resultView.layer.cornerRadius = 4 }
    }

    @IBOutlet weak var genderLabel: UILabel! {
        didSet { genderLabel.text = "..." }
    }

    @IBOutlet weak var ageLabel: UILabel! {
        didSet { ageLabel.text = "..." }
    }

    private lazy var cameraSession = AVCaptureSession()

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: cameraSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()

    private let sessionQueue = DispatchQueue(label: "com.fritz.heartbeat.human.session", attributes: .concurrent)

    private let captureQueue = DispatchQueue(label: "com.fritz.heartbeat.human.capture", attributes: .concurrent)
    
    private var maskLayer: [CAShapeLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front), let input = try? AVCaptureDeviceInput(device: device) else { return }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: captureQueue)

        sessionQueue.async {
            self.cameraSession.beginConfiguration()
            self.cameraSession.addInput(input)
            self.cameraSession.addOutput(output)
            self.cameraSession.commitConfiguration()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        previewLayer.frame = view.layer.bounds
        view.layer.insertSublayer(previewLayer, at: 0)

        sessionQueue.async {
            self.cameraSession.startRunning()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        previewLayer.frame = view.layer.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(
            alongsideTransition: { _ in
                self.previewLayer.frame = CGRect(origin: .zero, size: size)
            },
            completion: nil
        )
    }
}

extension HumanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        connection.videoOrientation = .portrait

        let options = VisionFaceDetectorOptions()
        options.modeType = .fast
        options.landmarkType = .all
        options.classificationType = .none
        options.minFaceSize = CGFloat(0.1)
        options.isTrackingEnabled = false
        
        let faceDetector = vision.faceDetector(options: options)
        
        let metadata = VisionImageMetadata()
        metadata.orientation = .topLeft
        
        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.metadata = metadata
        
        faceDetector.detect(in: visionImage) { (faces, error) in
            guard error == nil, let faces = faces, !faces.isEmpty else {
                // Error. You should also check the console for error messages.
                // ...
                return
            }
            
            // Faces detected
            // ...
            print("some faces detected?")
            
            DispatchQueue.main.async {
                self.removeMask()
                for face in faces {
                    self.drawFaceWithLandmarks(face: face)
                    
                    let frame = face.frame
                    print(frame.debugDescription)
                    self.drawFaceFrame(rect: frame)
                    
                    if face.hasHeadEulerAngleY {
                        let rotY = face.headEulerAngleY  // Head is rotated to the right rotY degrees
                        self.genderLabel.text = NSString(format: "%.2f", rotY) as String
                    }
                    if face.hasHeadEulerAngleZ {
                        let rotZ = face.headEulerAngleZ  // Head is rotated upward rotZ degrees
                        self.ageLabel.text = NSString(format: "%.2f", rotZ) as String
                    }
                    
                    // If landmark detection was enabled (mouth, ears, eyes, cheeks, and
                    // nose available):
                    if let leftEye = face.landmark(ofType: .leftEye) {
                        let leftEyePosition = leftEye.position
                        print(leftEyePosition)
                    }
                    
                    // If classification was enabled:
                    if face.hasSmilingProbability {
                        let smileProb = face.smilingProbability
                        print(smileProb)
                    }
                    if face.hasRightEyeOpenProbability {
                        let rightEyeOpenProb = face.rightEyeOpenProbability
                        print(rightEyeOpenProb)
                    }
                    
                    // If face tracking was enabled:
                    if face.hasTrackingID {
                        let trackingId = face.trackingID
                        print(trackingId)
                    }
                }
            }
        }
    }
}

extension HumanViewController {

    // Create a new layer drawing the bounding box
    private func createLayer(in rect: CGRect) -> CAShapeLayer{

        let mask = CAShapeLayer()
        mask.frame = rect
        mask.cornerRadius = 10
        mask.opacity = 0.75
        mask.borderColor = UIColor.yellow.cgColor
        mask.borderWidth = 2.0

        maskLayer.append(mask)
        previewLayer.insertSublayer(mask, at: 1)

        return mask
    }

    
    
    // Create a new layer drawing the bounding box
    func drawFaceFrame(rect: CGRect) -> CAShapeLayer{
        
        let mask = CAShapeLayer()
        mask.frame = rect
        mask.cornerRadius = 10
        mask.opacity = 0.75
        mask.borderColor = UIColor.yellow.cgColor
        mask.borderWidth = 2.0
        
        maskLayer.append(mask)
        previewLayer.insertSublayer(mask, at: 1)
        
        return mask
    }

    
    func drawFaceWithLandmarks(face: VisionFace) {
        let frame = previewLayer.frame

        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)

        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)

        // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
        let facebounds = face.frame.applying(translate).applying(transform)

        // Draw the bounding rect
        let faceLayer = createLayer(in: facebounds)

        // Draw the landmarks
        if let leftEye = face.landmark(ofType: .leftEye) {
            let leftEyePosition = leftEye.position
            drawLandmarks(on: faceLayer, visionPoint: leftEyePosition)
        }
        
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.land)!, isClosed:false)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.noseCrest)!, isClosed:false)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.medianLine)!, isClosed:false)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.leftEye)!)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.leftPupil)!)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.leftEyebrow)!, isClosed:false)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightEye)!)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightPupil)!)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightEye)!)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightEyebrow)!, isClosed:false)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.innerLips)!)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.outerLips)!)
//        drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.faceContour)!, isClosed: false)
    }



    func drawLandmarks(on targetLayer: CALayer, visionPoint: VisionPoint) {
        let rect: CGRect = targetLayer.frame
        
        let landmarkLayer = drawPointsOnLayer(rect: rect, landmarkPoint: visionPoint)

        // Change scale, coordinate systems, and mirroring
//        landmarkLayer.transform = CATransform3DMakeAffineTransform(
//            CGAffineTransform.identity
//                .scaledBy(x: rect.width, y: -rect.height)
//                .translatedBy(x: 0, y: -1)
       // )

        targetLayer.insertSublayer(landmarkLayer, at: 1)
    }

    func drawPointsOnLayer(rect:CGRect, landmarkPoint: VisionPoint) -> CALayer {
        
        let center = CGPoint(x: CGFloat(landmarkPoint.x), y: CGFloat(landmarkPoint.y))
        
        let circlePath = UIBezierPath(
            arcCenter: center,
            radius: CGFloat(10),
            startAngle: CGFloat(0),
            endAngle: CGFloat(2 * Double.pi),
            clockwise: true)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = circlePath.cgPath
        lineLayer.fillColor = nil
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = UIColor.green.cgColor
        lineLayer.lineWidth = 0.02

        return lineLayer
    }

    func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
}

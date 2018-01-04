//
//  InceptionViewController.swift
//  Heartbeat
//
//  Created by Andrew Barba on 1/3/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage
import Fritz

class InceptionViewController: UIViewController {

    @IBOutlet weak var resultView: UIView! {
        didSet {
            resultView.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var predictionLabel: UILabel!

    @IBOutlet weak var confidenceLabel: UILabel!

    private let cameraSession = AVCaptureSession()

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()

    private let model = Inception().fritz()

    private let sessionQueue = DispatchQueue(label: "com.fritz.heartbeat.inception", attributes: .concurrent)

    override func viewDidLoad() {
        super.viewDidLoad()

        predictionLabel.text = "Loading... 🚀"
        confidenceLabel.text = nil

        let captureDevice = AVCaptureDevice.default(for: .video)!

        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)

            cameraSession.beginConfiguration()

            if (cameraSession.canAddInput(deviceInput)) {
                cameraSession.addInput(deviceInput)
            }

            let dataOutput = AVCaptureVideoDataOutput()

            dataOutput.videoSettings = [
                ((kCVPixelBufferPixelFormatTypeKey as NSString) as String): NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)
            ]

            dataOutput.alwaysDiscardsLateVideoFrames = true

            if (cameraSession.canAddOutput(dataOutput)) {
                cameraSession.addOutput(dataOutput)
            }

            cameraSession.commitConfiguration()

            dataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        } catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var frame = view.frame
        frame.size.height = frame.size.height - 35.0
        previewLayer.frame = frame

        view.layer.insertSublayer(previewLayer, at: 0)
        cameraSession.startRunning()
    }
}

extension InceptionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        connection.videoOrientation = .portrait

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let uiImage = UIImage(ciImage: ciImage).af_imageAspectScaled(toFill: .init(width: 299, height: 299))
        let pixelBuffer = uiImage.buffer()!
        guard let output = try? model.prediction(image: pixelBuffer) else {
            return setResult(text: "Not sure... 😞", confidence: nil)
        }
        setResult(text: output.classLabel, confidence: output.classLabelProbs[output.classLabel])
    }

    private func setResult(text: String, confidence: Double?) {
        DispatchQueue.main.async {
            self.predictionLabel.text = text.capitalized
            if let confidence = confidence {
                let percent = Int(confidence * 100)
                self.confidenceLabel.text = "\(percent)%"
                switch percent {
                case ...33:
                    self.confidenceLabel.textColor = .red
                case 34...66:
                    self.confidenceLabel.textColor = .orange
                case 67...:
                    self.confidenceLabel.textColor = .green
                default:
                    break
                }
            } else {
                self.confidenceLabel.text = nil
            }
        }
    }
}

extension UIImage {

    // https://stackoverflow.com/questions/44462087/how-to-convert-a-uiimage-to-a-cvpixelbuffer
    // https://www.hackingwithswift.com/whats-new-in-ios-11
    func buffer() -> CVPixelBuffer? {
        let image = self
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}

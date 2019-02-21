//
//  PoseEstimationViewController
//  Heartbeat
//
//  Created by Chris Kelly on 9/12/2018.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage
import Vision
import Fritz
import VideoToolbox


class PoseEstimationViewController: UIViewController {

    var cameraView: UIImageView!

    private lazy var cameraSession = AVCaptureSession()

    private let visionModel = FritzVisionPoseModel()

    private let sessionQueue = DispatchQueue(label: "com.fritz.heartbeat.mobilenet.session")

    private let captureQueue = DispatchQueue(label: "com.fritz.heartbeat.mobilenet.capture", qos: DispatchQoS.userInitiated)

    internal var poseThreshold: Double = 0.3

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView = UIImageView(frame: view.frame)
        cameraView.contentMode = .scaleAspectFill
        view.addSubview(cameraView)

        guard let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device) else { return }

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
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

        sessionQueue.async {
            self.cameraSession.startRunning()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        cameraView.frame = view.frame
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
}


extension PoseEstimationViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        let image = FritzVisionImage(buffer: sampleBuffer)
        image.metadata = FritzVisionImageMetadata()

        let options = FritzVisionPoseModelOptions()
        options.minPoseThreshold = poseThreshold

        visionModel.predict(image, options: options) { [weak self] (results, error) in
            guard let poseResult = results, let pose = poseResult.decodePose() as Pose? else {
                // Handle case where failed to detect a pose, still draw empty image
                if let rotated = image.rotate() {
                    let img = UIImage(pixelBuffer: rotated)
                    DispatchQueue.main.async {
                        self?.cameraView.image = img
                    }
                }
                return
            }

            let img = poseResult.drawPose(pose)
            DispatchQueue.main.async {
                self?.cameraView.image = img
            }

        }
    }
}


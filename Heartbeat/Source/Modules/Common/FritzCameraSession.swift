//
//  FritzCameraSession.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 3/6/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import AVFoundation

import Fritz

public protocol FritzCameraDelegate: class {

    func capture(_ cameraSession: FritzVisionCameraSession, didCaptureFritzImage image: FritzVisionImage?, timestamp: Date)
}


public class FritzVisionCameraSession: NSObject {


    var session: AVCaptureSession?
    var device: AVCaptureDevice!

    var captureVideoInput: AVCaptureInput!
    var captureVideoOutput: AVCaptureVideoDataOutput!

    private let sessionQueue = DispatchQueue(label: "com.fritz.heartbeat.cameravision.session")

    private let captureQueue = DispatchQueue(label: "com.fritz.heartbeat.mobilenet.capture", qos: DispatchQoS.userInitiated)

    public weak var delegate: FritzCameraDelegate?

    public var sessionPreset: AVCaptureSession.Preset?

    func configure()
    {
        sessionQueue.sync {
            guard session == nil else { return }
            // TODO: register for AVCaptureSessionRuntimeError, AVCaptureSessionDidStartRunning, AVCaptureSessionDidStopRunning, AVCaptureSessionWasInterrupted, AVCaptureSessionInterruptionEndedNotification
            // TODO: register for UIApplicationWillEnterForegroundNotification in case runtime error reason was AVErrorDeviceIsNotAvailableInBackground

            session = AVCaptureSession()
            guard let session = session else { return }

            if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                device = backCamera
            } else {
                fatalError("Unable to acess the back camera. Please make sure the device supports a front-facing camera.")
            }

            try! device.lockForConfiguration()
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 5)
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
            device.unlockForConfiguration()

            guard let videoInput = try? AVCaptureDeviceInput(device: device) else {
                fatalError("Unable to obtain video input for default camera.")
            }
            captureVideoInput = videoInput


            captureVideoOutput = AVCaptureVideoDataOutput()
            captureVideoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]

            captureVideoOutput.alwaysDiscardsLateVideoFrames = true

            guard session.canAddInput(captureVideoInput) else { fatalError("Cannot add input") }
            guard session.canAddOutput(captureVideoOutput) else { fatalError("Cannot add output") }

            session.beginConfiguration()
            session.addInput(captureVideoInput)
            if let sessionPreset = sessionPreset {
                session.sessionPreset = sessionPreset
            }
            session.addOutput(captureVideoOutput)
            session.commitConfiguration()

            captureVideoOutput.connection(with: .video)?.videoOrientation = .portrait
        }
    }
    func setDelegate(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        captureVideoOutput.setSampleBufferDelegate(delegate, queue: captureQueue)
    }

    public func start() {
        sessionQueue.async {
            guard let session = self.session else { return }
            session.startRunning()
        }
    }

    public func stop() {
        sessionQueue.async {
            guard let session = self.session else { return }
            session.stopRunning()
        }
    }
}


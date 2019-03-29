//
//  ModelConfigButton.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 3/6/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz
import AVFoundation
import Photos


public protocol RunImageModelDelegate: class {
    func display(_ image: UIImage?)
}


class FritzCameraViewController: UIViewController, RunImageModelDelegate {

    var backgroundImageView: UIImageView!

    var imageView: UIImageView!

    var fritzCameraSession: FritzVisionCameraSession!

    var sessionPreset: AVCaptureSession.Preset?

    var showBackgroundImage = false {
        didSet {
            backgroundImageView?.isHidden = !showBackgroundImage
        }
    }

    weak var delegate: FritzCameraDelegate?

    func setUpImageView() {
        imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFill


        backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView?.isHidden = !showBackgroundImage
        
        view.addSubview(backgroundImageView!)
        view.insertSubview(backgroundImageView!, at: 0)
        view.addSubview(imageView)
    }

    func setUpCamera() {
        fritzCameraSession = FritzVisionCameraSession()
        fritzCameraSession.sessionPreset = sessionPreset
        fritzCameraSession.configure()
        fritzCameraSession.setDelegate(self)
        fritzCameraSession.start()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpImageView()
        checkAndSetupCamera()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageView.frame = view.frame
        backgroundImageView?.frame = view.frame
    }

    func checkAndSetupCamera() {
        checkAuthorization(for: .camera) { [unowned self] (success) in
            if success {
                self.setUpCamera()
            } else {
                showAuthorizationRequiredAlert(for: .camera, from: self)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fritzCameraSession.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fritzCameraSession.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(#function)
    }

    public func display(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}

extension FritzCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let image = FritzVisionImage(buffer: sampleBuffer)
        image.metadata = FritzVisionImageMetadata()
        let orientation = FritzImageOrientation(from: connection)
        image.metadata?.orientation = orientation
        self.delegate?.capture(fritzCameraSession, didCaptureFritzImage: image, timestamp: Date())

        if showBackgroundImage, let rotated = image.rotate() {
            let uiImage = UIImage(pixelBuffer: rotated)
            DispatchQueue.main.async {
                self.backgroundImageView?.image = uiImage
            }
        }
    }
}

// Camera and Photo Library authorization handling
enum AuthorizationType {
    case camera
    case photoLibrary
}

private func checkAuthorization(for type: AuthorizationType, _ completion: @escaping ((_ autorized: Bool) -> Void)) {
    switch type {
    case .camera:
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)

        case .denied:
            fallthrough
        case .restricted:
            completion(false)
        }
    case .photoLibrary:
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completion(true)

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                completion(status == .authorized)
            })

        case .denied:
            fallthrough
        case .restricted:
            completion(false)
        }
    }
}

private func showAuthorizationRequiredAlert(for type: AuthorizationType, from controller: UIViewController) {
    let alertController: UIAlertController
    if type == .camera {
        alertController = UIAlertController(title: "Camera Access", message: "Camera Access is requied to run this demo and can be changed in Settings | Privacy | Camera.", preferredStyle: .alert)
    } else {
        alertController = UIAlertController(title: "Photo Library Access", message: "Photo Library Access is requied to run this demo and can be changed in Settings | Privacy | Photos.", preferredStyle: .alert)
    }
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
        alertController.dismiss(animated: true, completion: nil)
    }))
    controller.present(alertController, animated: true, completion: nil)
}

//
//  FeatureViewController.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//


import UIKit
import AVFoundation


class FeatureViewController<Feature: HeartbeatFeature>: UIViewController {

    @IBOutlet weak var infoButton: UIButton!

    var modelGroup: ModelGroupManager<Feature>!

    var runImageController: FritzCameraViewController! {
        didSet {
            runImageController.delegate = feature
            feature?.delegate = runImageController
        }
    }

    var feature: Feature? {
        didSet {
            self.runImageController.delegate = feature
            feature?.delegate = runImageController
        }
    }

    var showBackgroundView: Bool = false {
        didSet {
            if runImageController != nil {
                runImageController.showBackgroundImage = showBackgroundView
            }
        }
    }
    var sessionPreset: AVCaptureSession.Preset?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FeatureSettings" {
            let navVC = segue.destination as! UINavigationController
            let topVC = navVC.topViewController
            guard let featureConfigVC = topVC as? ConfigureFeaturePopoverViewController<Feature> else {
                return
            }
            featureConfigVC.models = modelGroup.models
            featureConfigVC.selectedFeature = feature
            featureConfigVC.options = feature?.options ?? [:]
            return
        }
    }

    @IBAction func unwindWithUpdate(segue: UIStoryboardSegue) {
        if let modelConfigViewController = segue.source as? ConfigureFeaturePopoverViewController<Feature> {
            // Add options to feature regardless if it's changed or not.
            self.feature?.options = modelConfigViewController.options
            if let selectedFeature = modelConfigViewController.selectedFeature, selectedFeature.fritzModel != modelGroup.selectedModel {
                modelGroup.selectedModel = selectedFeature.fritzModel
                self.feature = selectedFeature
            }
        }
    }

    @IBAction func unwindWithCancel(segue: UIStoryboardSegue) { }

    @IBAction func clickInfo(_ sender: UIButton) {
        guard let selectedModel = modelGroup.selectedModel else { return }
        let alertController = UIAlertController(title: selectedModel.name, message: selectedModel.description, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel)

        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tagName = Feature.tagName {
            modelGroup.fetchModels(for: [tagName])
        }
        setUpContainerView()
        view.bringSubviewToFront(infoButton)
    }

    func setUpContainerView() {
        let runImageController = FritzCameraViewController()
        runImageController.showBackgroundImage = showBackgroundView
        runImageController.sessionPreset = sessionPreset
        self.runImageController = runImageController

        view.addSubview(runImageController.view)
        addChild(runImageController)

        runImageController.didMove(toParent: self)
        runImageController.view.frame = view.frame
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if runImageController != nil {
            runImageController.fritzCameraSession.start()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if runImageController != nil {
            runImageController.fritzCameraSession.stop()
        }
    }
}

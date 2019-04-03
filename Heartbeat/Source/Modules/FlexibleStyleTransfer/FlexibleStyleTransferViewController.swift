//
//  FlexibleStyleTransferViewController.swift
//  Heartbeat
//
//  Created by Jameson Toole on 6/8/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Vision
import CoreML
import Fritz


extension kaleidoscope_512x512_a025_stable_flexible: SwiftIdentifiedModel {
    static let modelIdentifier = "8c07e18043b547748150356b4faae7e1"
    static let packagedModelVersion = 1
}

extension FritzVisionFlexibleStyleModel: ImagePredictor {
    func predict(_ image: FritzVisionImage?, options: ConfigurableOptions, completion: (UIImage?, Error?) -> Void) {

        guard let fritzImage = image else {
            completion(nil, nil)
            return
        }
        let value = options[.modelResolution] as! SegmentValue
        // This is a bit hacky, but we can change it if it becomes a problem
        let index = value.selectedIndex
        let styleOptions = FritzVisionFlexibleStyleModelOptions()
        if index == 0 {
            styleOptions.flexibleModelDimensions = .lowResolution
        } else if index == 1 {
            styleOptions.flexibleModelDimensions = .mediumResolution
        } else if index == 2 {
            styleOptions.flexibleModelDimensions = .highResolution
        } else if index == 3 {
            styleOptions.flexibleModelDimensions = .original
        }

        predict(fritzImage, options: styleOptions) { (buffer: CVPixelBuffer?, error: Error?) in
            guard let stylizedBuffer = buffer else {
                completion(nil, error)
                return
            }
            guard let originalSize = fritzImage.size,
                let resized = resizePixelBuffer(stylizedBuffer, width: Int(originalSize.width) , height: Int(originalSize.height))
                else {
                    return
                }
            let outputImage = UIImage(pixelBuffer: resized)

            completion(outputImage, nil)
        }
    }
}


final class FlexibleStyleTransfer: HeartbeatFeature {

    static var tagName: String? = "heartbeat-ios-flexible-style-transfer"

    let model: FritzVisionFlexibleStyleModel

    let fritzModel: FritzModel

    var options: ConfigurableOptions = [
        .modelResolution: SegmentValue(optionType: .modelResolution, options: ["Low", "Medium", "High", "Original"], selectedIndex: 0)
    ]

    public weak var delegate: RunImageModelDelegate?

    public init(model: FritzVisionFlexibleStyleModel, fritzModel: FritzModel) {
        self.model = model
        self.fritzModel = fritzModel
    }

    enum FlexibleStyleModels: String, RawRepresentable, CaseIterable {
        case flexibleStyleTransfer = "flexible_style_transfer"
    }

    static func build(from heartbeatModel: FritzModel, featureModel model: FritzMLModel) -> FlexibleStyleTransfer? {
        guard let modelType = FlexibleStyleModels(rawValue: heartbeatModel.featureName) else { return nil }

        switch modelType {
        case .flexibleStyleTransfer:
            if let model = try? FritzVisionFlexibleStyleModel(model: model) {
                return FlexibleStyleTransfer(model: model, fritzModel: heartbeatModel)
            }
            return nil
        }
    }
}


class FlexibleStyleTransferViewController: FeatureViewController<FlexibleStyleTransfer> {

    @IBOutlet weak var frameLabel: UILabel!

    override func viewDidLoad() {
        setUpModels()
        self.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        self.showBackgroundView = true
        super.viewDidLoad()
        feature = nil
        // Tap anywhere on the screen to change the current model.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        self.feature = modelGroup.selectedModel?.buildFeature()
    }

    @objc func tapped() {
        activateNextStyle()
    }

    func setUpModels() {
        let managedModel = FritzManagedModel(identifiedModelType: kaleidoscope_512x512_a025_stable_flexible.self)
        let models: [FritzModel] = [
            FritzModel(with: managedModel,
                       predefinedFeatureName: FlexibleStyleTransfer.FlexibleStyleModels.flexibleStyleTransfer.rawValue)
        ]
        modelGroup = ModelGroupManager<FlexibleStyleTransfer>(models: models, selectedModel: models[0])
    }

    private func updateFeature(_ model: FritzModel) {
        if let feature: FlexibleStyleTransfer = model.buildFeature() {
            // When switching features, carry over options from one model to the next.
            if let options = self.feature?.options {
                feature.options = options
            }
            self.feature = feature
        }
    }

    func activateNextStyle() {
        let allModels = modelGroup.models

        // No index, choose first one,
        guard let selectedModel = modelGroup.selectedModel,
            let index = allModels.index(of: selectedModel),
            index != allModels.count - 1 else {
                // If there is not a selected model, or the model is the last
                // model, start at the beginining. Ideally, we would show the plain
                // image, but there is a small still untraced bug in the FritzCameraViewController blocking that.

                let newModel = modelGroup.models[0]
                // Model is the same model that is already loaded.
                if newModel == modelGroup.selectedModel {
                    return
                }
                modelGroup.selectedModel = newModel
                updateFeature(newModel)

                return
        }

        // Normal model, just take the next one
        let nextModel = allModels[index + 1]
        modelGroup.selectedModel = nextModel
        updateFeature(nextModel)
    }
}

class FlexibleStyleTransferChooseFeatureTableViewController: ChooseModelTableViewController<FlexibleStyleTransfer> { }

class FlexibleStyleTransferConfigureFeatureViewController: ConfigureFeaturePopoverViewController<FlexibleStyleTransfer> { }

//
//  StyleTransferViewController.swift
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




extension FritzVisionStyleModel: ImagePredictor {
    func predict(_ image: FritzVisionImage?, options: ConfigurableOptions, completion: (UIImage?, Error?) -> Void) {

        guard let fritzImage = image else {
            completion(nil, nil)
            return
        }

        let options =  FritzVisionStyleModelOptions()
        options.forceCoreMLPrediction = true
        predict(fritzImage, options: options) { (buffer: CVPixelBuffer?, error: Error?) in
            guard let stylizedBuffer = buffer else {
                completion(nil, error)
                return
            }
            let uiImage = UIImage(pixelBuffer: stylizedBuffer)
            completion(uiImage, nil)
        }
    }
}


final class StyleTransfer: HeartbeatFeature {
    static var tagName: String? = "heartbeat-ios-style-transfer"

    let model: FritzVisionStyleModel

    let fritzModel: FritzModel

    var options: ConfigurableOptions = [:]

    public weak var delegate: RunImageModelDelegate?

    public init(model: FritzVisionStyleModel, fritzModel: FritzModel) {
        self.model = model
        self.fritzModel = fritzModel
    }

    enum StyleModels: String, RawRepresentable, CaseIterable {
        case customStyleTransfer = "custom_style_transfer"
        // Generally the raw
        case starryNight
        case pinkBlueRhombus
        case theScream
        case bicentennialPrint
        case poppyField
        case kaleidoscope
        case femmes
        case headOfClown
        case horsesOnSeashore
        case theTrial
        case ritmoPlastico
    }


    static func build(from heartbeatModel: FritzModel, featureModel model: FritzMLModel) -> StyleTransfer? {
        guard let modelType = StyleModels(rawValue: heartbeatModel.featureName) else { return nil }

        switch modelType {
        case .customStyleTransfer:
            if let model = try? FritzVisionStyleModel(model: model) {
                return StyleTransfer(model: model, fritzModel:heartbeatModel)
            }
            return nil
        default:
            // A bit of a hacky way to get the prepackaged models.
            if let model = FritzVisionStyleModel.value(forKey: modelType.rawValue) as? FritzVisionStyleModel {
                return StyleTransfer(model: model, fritzModel:heartbeatModel)
            }
            return nil
        }
    }

    static func build(from heartbeatModel: FritzModel) -> StyleTransfer? {
        guard let modelType = StyleModels(rawValue: heartbeatModel.featureName) else { return nil }

        switch modelType {
        case .customStyleTransfer:
            return nil
        default:
            if let paintingStyle = PaintingStyleModel.Style.getFromName(heartbeatModel.featureName) {
                return StyleTransfer(model: paintingStyle.build(), fritzModel:heartbeatModel)
            }
            return nil
        }
    }
}


class StyleTransferViewController: FeatureViewController<StyleTransfer> {

    @IBOutlet weak var frameLabel: UILabel!

    override func viewDidLoad() {
        setUpModels()
        self.showBackgroundView = true
        self.sessionPreset = AVCaptureSession.Preset.vga640x480
        super.viewDidLoad()
        // Tap anywhere on the screen to change the current model (hack for now)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        self.feature = modelGroup.selectedModel?.buildFeature()
    }
    
    @objc func tapped() {
        activateNextStyle()
    }

    func setUpModels() {
        var models: [FritzModel] = []

        for paintingStyle in PaintingStyleModel.Style.allCases {
            let styleModel = paintingStyle.build()
            let fritzModel = FritzModel(
                with: styleModel.managedModel,
                predefinedFeatureName: paintingStyle.name)
            models.append(fritzModel)
        }
        modelGroup = ModelGroupManager<StyleTransfer>(models: models, selectedModel: models[0])
    }

    func updateFeature(_ fritzModel: FritzModel) {
        if let feature: StyleTransfer = fritzModel.buildFeature() {
            let currentFeature = self.feature
            self.feature = feature
            self.showBackgroundView = false
            currentFeature?.delegate = nil
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


class StyleTransferChooseFeatureTableViewController: ChooseModelTableViewController<StyleTransfer> { }

class StyleTransferConfigureFeatureViewController: ConfigureFeaturePopoverViewController<StyleTransfer> { }

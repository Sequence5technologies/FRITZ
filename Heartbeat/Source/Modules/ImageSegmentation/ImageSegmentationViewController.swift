//
//  ImageSegmentationViewController
//  Heartbeat
//
//  Created by Chris Kelly on 9/12/2018.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import Fritz
import VideoToolbox


extension FritzVisionSegmentationModel: ImagePredictor {

    func predict(_ image: FritzVisionImage?, options: ConfigurableOptions, completion: (UIImage?, Error?) -> Void) {

        guard let fritzImage = image else { return }

        let unsafeOptions = FritzVisionSegmentationModelOptions.defaults as! FritzVisionSegmentationModelOptions

        self.predict(fritzImage, options: unsafeOptions) { (mask, error) in
            guard let mask = mask else {
                return
            }

            let minThreshold = Double((options[.minThreshold] as! RangeValue).value)
            let alpha = UInt8((options[.alpha] as! RangeValue).value)

            let image = mask.toImageMask(minThreshold: minThreshold, alpha: alpha)
            completion(image, error)
        }
    }
}

/// Image Segmentation feature. Segments images into different classes.  For more information, see https://docs.fritz.ai/develop/vision/image-segmentation/about.html.
final class ImageSegmentation: HeartbeatFeature {

    static let tagName: String? = "heartbeat-ios-image-segmentation"

    var options: [ConfigurableOptionType:FeatureOption] = [
        .minThreshold: RangeValue(optionType: .minThreshold, min: 0.0, max: 1.0, value: 0.5),
        .alpha: RangeValue(optionType: .alpha, min: 0.0, max: 255.0, value: 255.0)
    ]

    let model: FritzVisionSegmentationModel

    let fritzModel: FritzModel

    public weak var delegate: RunImageModelDelegate?

    public init(model: FritzVisionSegmentationModel, fritzModel: FritzModel) {
        self.model = model
        self.fritzModel = fritzModel
    }

    enum SegmentationModels: String, RawRepresentable {
        case peopleSegmentation = "people_image_segmentation"
        case livingRoomSegmentation = "living_room_segmentation"
        case outdoorSegmentation = "outdoor_image_segmentation"
    }

    static func build(from heartbeatModel: FritzModel, featureModel model: FritzMLModel) -> ImageSegmentation? {
        guard let modelType = SegmentationModels(rawValue: heartbeatModel.featureName) else { return nil }

        var segmentationModel: FritzVisionSegmentationModel? = nil
        switch modelType {
        case .peopleSegmentation:
            segmentationModel = FritzVisionPeopleSegmentationModel(model: model)

        case .livingRoomSegmentation:
            segmentationModel = FritzVisionLivingRoomSegmentationModel(model: model)

        case .outdoorSegmentation:
            segmentationModel = FritzVisionOutdoorSegmentationModel(model: model)
        }
        if let segmentationModel = segmentationModel {
            return ImageSegmentation(model: segmentationModel, fritzModel: heartbeatModel)
        }
        return nil
    }
}


class ImageSegmentationViewController: FeatureViewController<ImageSegmentation> {



    override func viewDidLoad() {
        // People segmentation model is included in the default build.
        let peopleSeg = FritzModel(
            with: FritzVisionPeopleSegmentationModel().managedModel,
            predefinedFeatureName: "people_image_segmentation")
        self.showBackgroundView = true
        let models = [peopleSeg]
        modelGroup = ModelGroupManager<ImageSegmentation>(models: models, selectedModel: peopleSeg)

        super.viewDidLoad()
        self.feature = ImageSegmentation(model: FritzVisionPeopleSegmentationModel(), fritzModel: peopleSeg)
    }
}


class ImageSegmentationChooseFeatureTableViewController: ChooseModelTableViewController<ImageSegmentation> { }

class ImageSegmentationConfigureFeatureViewController: ConfigureFeaturePopoverViewController<ImageSegmentation> { }

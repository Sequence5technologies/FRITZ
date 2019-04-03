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


extension FritzVisionPoseModel: ImagePredictor {

    func predict(_ image: FritzVisionImage?, options: ConfigurableOptions, completion: (UIImage?, Error?) -> Void) {

        guard let fritzImage = image else { return }
        let poseOptions = FritzVisionPoseModelOptions()
        poseOptions.minPoseThreshold = Double((options[.minPoseThreshold] as! RangeValue).value)
        poseOptions.minPartThreshold = Double((options[.minPartThreshold] as! RangeValue).value)

        predict(fritzImage, options: poseOptions) { (results, error) in
            guard let poseResult = results else {
                // Handle case where failed to detect a pose, still draw empty image
                if let rotated = fritzImage.rotate() {
                    completion(UIImage(pixelBuffer: rotated), nil)
                }
                return
            }

            // The multi-pose model is part of the Fritz Premium package. To see a demo,
            // Download Heartbeat from the App Store https://itunes.apple.com/us/app/heartbeat-by-fritz/id1325206416?mt=8.
            #if canImport(FritzVisionMultiPoseModel)
            if let numPoseOption = options[.numPoses] as? RangeValue {
                completion(poseResult.drawPoses(numPoses: Int(numPoseOption.value)), nil)
                return
            }
            #endif

            if let pose = poseResult.decodePose() {
                completion(poseResult.drawPose(pose), nil)
                return
            }

            // If we did not detect any poses, Draw the original image.
            if let rotated = fritzImage.rotate() {
                completion(UIImage(pixelBuffer: rotated), nil)
            } else {
                completion(nil, nil)
            }
        }
    }
}


final class PoseEstimation: HeartbeatFeature {
    static let tagName: String? = nil

    var options: [ConfigurableOptionType:FeatureOption]

    let model: FritzVisionPoseModel

    let fritzModel: FritzModel

    public weak var delegate: RunImageModelDelegate?

    public init(model: FritzVisionPoseModel, fritzModel: FritzModel) {
        self.model = model
        self.fritzModel = fritzModel
        self.options = [:]
    }

    public init(model: FritzVisionPoseModel, fritzModel: FritzModel, options: ConfigurableOptions) {
        self.model = model
        self.fritzModel = fritzModel
        self.options = options
    }

    enum PoseModels: String, RawRepresentable {
        case singlePose = "single_pose"
        case multiPose = "multi_pose"
    }

}

extension PoseEstimation {
    private static func build(from heartbeatModel: FritzModel, poseModel: FritzVisionPoseModel) -> PoseEstimation? {
        guard let modelType = PoseModels(rawValue: heartbeatModel.featureName) else { return nil }
        
        switch modelType {
        case .singlePose:
            let singlePoseOptions: ConfigurableOptions = [
                .minPoseThreshold: RangeValue(optionType: .minPoseThreshold, min: 0.0, max: 1.0, value: 0.5),
                .minPartThreshold: RangeValue(optionType: .minPartThreshold, min: 0.0, max: 1.0, value: 0.5)
            ]
            return PoseEstimation(model: poseModel, fritzModel: heartbeatModel, options: singlePoseOptions)
        case .multiPose:
            let multiPoseOptions: ConfigurableOptions = [
                .minPoseThreshold: RangeValue(optionType: .minPoseThreshold, min: 0.0, max: 1.0, value: 0.5),
                .minPartThreshold: RangeValue(optionType: .minPartThreshold, min: 0.0, max: 1.0, value: 0.5),
                .numPoses: RangeValue(optionType: .numPoses, min: 1.0, max: 20.0, value: 7.0)
            ]
            return PoseEstimation(model: poseModel, fritzModel: heartbeatModel, options: multiPoseOptions)
        }
    }

    static func build(from heartbeatModel: FritzModel, featureModel model: FritzMLModel) -> PoseEstimation? {
        let poseModel = FritzVisionPoseModel(model: model)
        return build(from: heartbeatModel, poseModel: poseModel)

    }

    static func build(from heartbeatModel: FritzModel) -> PoseEstimation? {
        let poseModel = FritzVisionPoseModel()
        return build(from: heartbeatModel, poseModel: poseModel)
    }
}


class PoseEstimationViewController: FeatureViewController<PoseEstimation> {

    override func viewDidLoad() {
        let managedModel = FritzVisionPoseModel().managedModel
        let single = FritzModel(
            with: managedModel,
            predefinedFeatureName: "single_pose")
        var models = [single]

        // The multi-pose model is part of the Fritz Premium package. To see a demo,
        // Download Heartbeat from the App Store https://itunes.apple.com/us/app/heartbeat-by-fritz/id1325206416?mt=8.
        #if canImport(FritzVisionMultiPoseModel)
        let multi = FritzModel(
            with: managedModel,
            predefinedFeatureName: "multi_pose")
        models.append(multi)
        #endif

        modelGroup = ModelGroupManager<PoseEstimation>(models: models, selectedModel: single)

        super.viewDidLoad()

        self.feature = PoseEstimation.build(from: single)
    }
}

class PoseEstimationChooseFeatureTableViewController: ChooseModelTableViewController<PoseEstimation> { }

class PoseEstimationConfigureFeatureViewController: ConfigureFeaturePopoverViewController<PoseEstimation> { }

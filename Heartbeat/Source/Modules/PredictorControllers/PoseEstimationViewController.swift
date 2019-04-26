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



class PoseEstimationViewController: FeatureViewController {

  static let defaultSinglePoseOptions: ConfigurableOptions = [
    .minPoseThreshold: RangeValue(optionType: .minPoseThreshold, min: 0.0, max: 1.0, value: 0.5, priority: 0),
    .minPartThreshold: RangeValue(optionType: .minPartThreshold, min: 0.0, max: 1.0, value: 0.5, priority: 1)
  ]

  static let multiPoseOptions: ConfigurableOptions = [
    .minPoseThreshold: RangeValue(optionType: .minPoseThreshold, min: 0.0, max: 1.0, value: 0.5, priority: 0),
    .minPartThreshold: RangeValue(optionType: .minPartThreshold, min: 0.0, max: 1.0, value: 0.5, priority: 1),
    .numPoses: RangeValue(optionType: .numPoses, min: 1.0, max: 20.0, value: 7.0, priority: 2)
  ]

  override var debugImage: UIImage? {
    return UIImage(named: "pose.jpg")
  }

  override func build(_ predictorDetails: FritzModelDetails) -> HeartbeatImagePredictor? {
    guard let mlmodel = predictorDetails.managedModel.loadModel()
      else { return nil }
    let poseModel = FritzVisionPoseModel(model: mlmodel)

    switch predictorDetails.featureDescription {
    case .poseEstimation:
      return HeartbeatImagePredictor(model: poseModel, predictorDetails: predictorDetails)
    case .multiPoseEstimation:
      return HeartbeatImagePredictor(model: poseModel, predictorDetails: predictorDetails)
    default: return nil
    }
  }

  convenience init() {
    let managedModel = FritzVisionPoseModel().managedModel
    let single = FritzModelDetails(
      with: managedModel,
      featureDescription: .poseEstimation)
    var models = [single]

    // The multi-pose model is part of the Fritz Premium package. To see a demo,
    // Download Heartbeat from the App Store https://itunes.apple.com/us/app/heartbeat-by-fritz/id1325206416?mt=8.
    #if canImport(FritzVisionMultiPoseModel)
    let multi = FritzModelDetails(
      with: managedModel,
      featureDescription: .multiPoseEstimation
    )
    models.append(multi)
    #endif

    let group = ModelGroupManager(with: models, initialModel: single, tagName: nil)
    self.init(modelGroup: group, title: "Pose Estimation")
  }
}

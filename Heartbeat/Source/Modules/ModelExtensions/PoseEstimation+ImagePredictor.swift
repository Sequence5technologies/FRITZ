//
//  PoseEstimation+ImagePredictor.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 4/23/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz

extension FritzVisionPoseModel: ImagePredictor {

  func predict(_ image: FritzVisionImage, options: ConfigurableOptions) throws -> UIImage? {

    let poseOptions = FritzVisionPoseModelOptions()
    poseOptions.minPoseThreshold = Double((options[.minPoseThreshold] as! RangeValue).value)
    poseOptions.minPartThreshold = Double((options[.minPartThreshold] as! RangeValue).value)

    let poseResult = try predict(image, options: poseOptions)
    // The multi-pose model is part of the Fritz Premium package. To see a demo,
    // Download Heartbeat from the App Store https://itunes.apple.com/us/app/heartbeat-by-fritz/id1325206416?mt=8.
    #if canImport(FritzVisionMultiPoseModel)
    if let numPoseOption = options[.numPoses] as? RangeValue {
      return poseResult.drawPoses(numPoses: Int(numPoseOption.value))
    }
    #endif

    if let pose = poseResult.decodePose() {
      return poseResult.drawPose(pose)
    }

    // If we did not detect any poses, Draw the original image.
    if let rotated = image.rotate() {
      return UIImage(pixelBuffer: rotated)
    }
    return nil
  }
}

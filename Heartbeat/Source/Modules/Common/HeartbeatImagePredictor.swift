//
//  HeartbeatFeature+Protocol.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz



class HeartbeatImagePredictor {

  let model: ImagePredictor

  let predictorDetails: FritzModelDetails

  init(model: ImagePredictor, predictorDetails: FritzModelDetails) {
    self.model = model
    self.predictorDetails = predictorDetails
  }
}

extension HeartbeatImagePredictor: FritzCameraControllerDelegate {

  public func processImage(_ image: FritzVisionImage?) throws -> UIImage? {
    guard let image = image else { return nil }
    return try self.model.predict(image, options: predictorDetails.options)
  }
  
}


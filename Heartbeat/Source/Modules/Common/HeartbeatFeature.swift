//
//  HeartbeatFeature+Protocol.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz

typealias ConfigurableOptions = [ConfigurableOptionType:FeatureOption]


protocol ImagePredictor {


    /// Runs prediction for a FritzVisionImage with user configurable options.
    ///
    /// A common use case of this Delegate is to extend an existing FritzVision model
    /// That just runs the predict method.
    ///
    /// - Parameters:
    ///   - image: FritzVisionImage with camera orientation settings applied.
    ///   - options: Options that can be be configured for the model.  These commonly can either be used to build the Model's options object or for postprocessing parameters.
    ///   - completion: Completion to call after image is processed.
    func predict(_ image: FritzVisionImage?, options: ConfigurableOptions, completion: (UIImage?, Error?) -> Void)
}


/// A feature that can be used in a `FeatureViewController`.
protocol HeartbeatFeature: FritzCameraDelegate {

    associatedtype FeatureType: ImagePredictor

    var model: FeatureType { get }

    var fritzModel: FritzModel { get }

    var options: ConfigurableOptions { get set }

    init(model: FeatureType, fritzModel: FritzModel)

    var delegate: RunImageModelDelegate? { get set }

    static var tagName: String? { get }

    /// Build Feature instance from heartbeat model.
    static func build(from heartbeatModel: FritzModel, featureModel model: FritzMLModel) -> Self?
}

extension HeartbeatFeature {
    public func capture(_ cameraSession: FritzVisionCameraSession, didCaptureFritzImage image: FritzVisionImage?, timestamp: Date) {
        self.model.predict(image, options: options) { image, error in
            self.delegate?.display(image)
        }
    }
}

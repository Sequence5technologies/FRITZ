//
//  HeartbeatModel.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 3/6/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz


class FritzModel: Equatable {

    static func == (lhs: FritzModel, rhs: FritzModel) -> Bool {
        // This is not the best way to do equality.  It's just checking that it's a
        // different model on the surface.  would be good to clean this up in the future.
        return lhs.modelConfig.version == rhs.modelConfig.version && lhs.modelConfig.identifier == rhs.modelConfig.identifier && lhs.featureName == rhs.featureName
    }

    /// Active Model Configuration for managed model.
    var modelConfig: FritzModelConfiguration {
        return managedModel.activeModelConfig
    }

    /// ManagedModel used to manage interactions with Fritz API.
    let managedModel: FritzManagedModel

    /// Optional feature name that will override any metadata property set in the webapp.
    let predefinedFeatureName: String?

    /// Feature name used to configure which variant of a feature is loaded.
    /// For example, ImageSegmentation defines three variants: people_segmentation, living_room_segmentation, and outdoor_segementation.
    public var featureName: String {
        return predefinedFeatureName ?? modelConfig.metadata?["fritz_feature"] ?? ""
    }

    /// Display name of model.
    public var name: String {
        return managedModel.activeModelConfig.metadata?["name"] ?? featureName
    }

    /// Description of model.
    public var description: String {
        return managedModel.activeModelConfig.metadata?["description"] ?? ""
    }

    /// Initialize FritzModel, a wrapper for a FritzManagedModel.
    ///
    /// - Parameters:
    ///   - managedModel: ManagedModel instance.
    ///   - predefinedFeatureName: Optional feature name that overrides any feature_name metadata property
    public init(with managedModel: FritzManagedModel, predefinedFeatureName: String? = nil) {
        self.managedModel = managedModel
        self.predefinedFeatureName = predefinedFeatureName
    }

    public func download() {
        managedModel.startDownload()
    }

    public var isDownloaded: Bool {
        return managedModel.hasDownloadedModel
    }

    /// Create HeartbeatFeature, handles whether or not the model is included or was downloaded OTA.
    public func buildFeature<Feature: HeartbeatFeature>() -> Feature? {
        guard let model = managedModel.loadModel() else {
            return nil
        }

        return Feature.build(from: self, featureModel: model)
    }
}

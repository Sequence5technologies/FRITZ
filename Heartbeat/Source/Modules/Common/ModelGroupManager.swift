//
//  ModelGroupManager.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Fritz


/// Manages available models for a HeartbeatFeature, including currently selected fetaure.
class ModelGroupManager {
  var models: [FritzModelDetails]
  var selectedPredictorDetails: FritzModelDetails?
  let tagName: String?

  init(initialModel model: FritzModelDetails, tagName: String?) {
    self.models = [model]
    self.selectedPredictorDetails = model
    self.tagName = tagName
  }

  init(with models: [FritzModelDetails], initialModel model: FritzModelDetails?, tagName: String?) {
    self.models = models
    self.selectedPredictorDetails = model
    self.tagName = tagName
  }


  init() {
    self.models = []
    self.selectedPredictorDetails = nil
    self.tagName = nil
  }

  // Fetch models for tags.
  func fetchModels() {
    guard let tagName = tagName else { return }
    let tags = ModelTagManager(tags: [tagName])
    tags.fetchManagedModelsForTags { models, error in
      guard let managedModels = models else { return }

      var newModels: [FritzModelDetails] = []

      // Indices of models in existing models that were also shared by the
      // tags response.  Helpful if you have models on device that are not tagged.
      var commonModelIndices: [Int] = []

      for model in managedModels {
        let featureName = model.activeModelConfig.metadata?["fritz_feature"] ?? ""
        let featureDescription = HeartbeatFeaturePredictors.init(rawValue: featureName)
        let newHeartbeatModel = FritzModelDetails(with: model, featureDescription: featureDescription ?? .unknown)

        if let index = self.models.firstIndex(of: newHeartbeatModel) {
          commonModelIndices.append(index)
          newModels.append(self.models[index])
        } else {
          newModels.append(newHeartbeatModel)
        }
      }

      // add existing models to newModels that were not udpated in tag query.
      for (i, model) in self.models.enumerated() {
        if commonModelIndices.contains(i) {
          continue
        }
        newModels.append(model)
      }

      self.models = newModels
    }
  }
}


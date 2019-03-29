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
class ModelGroupManager<Feature: HeartbeatFeature> {
    var models: [FritzModel]
    var selectedModel: FritzModel?

    init(models: [FritzModel], selectedModel: FritzModel?) {
        self.models = models
        self.selectedModel = selectedModel
    }

    convenience init() {
        self.init(models: [], selectedModel: nil)
    }

    // Fetch models for tags.
    func fetchModels(for tags: [String]) {
        let tags = ModelTagManager(tags: tags)
        tags.fetchManagedModelsForTags { models, error in
            guard let managedModels = models else { return }

            var newModels: [FritzModel] = []

            // Indices of models in existing models that were also shared by the
            // tags response.  Helpful if you have models on device that are not tagged.
            var commonModelIndices: [Int] = []

            for model in managedModels {
                let newHeartbeatModel = FritzModel(with: model)

                if let index = self.models.index(of: newHeartbeatModel) {
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


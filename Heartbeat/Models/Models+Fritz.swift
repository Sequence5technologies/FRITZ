//
//  Models+Fritz.swift
//  Heartbeat
//
//  Created by Andrew Barba on 1/6/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import Fritz

extension Inception: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "9a3da953e3b249ca9673cd2ffb78c64d"
}

extension MNIST: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "8cd3ee61b0d34b8e832977c0455d2d65"
}

extension AgeNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "5b376c236b3b40e2826061218c682499"
}

extension GenderNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "1aa1620864174fbcbba8efdd17d9dd32"
}

extension CNNEmotions: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "66b5830020784b26b804e74844bad42c"
}

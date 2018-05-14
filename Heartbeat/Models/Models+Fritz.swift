//
//  Models+Fritz.swift
//  Heartbeat
//
//  Created by Andrew Barba on 1/6/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//
import Fritz

extension MobileNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "de7974faf0d144fabcdce40c49a1d791"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension MNIST: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "8cd3ee61b0d34b8e832977c0455d2d65"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension AgeNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "5b376c236b3b40e2826061218c682499"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension GenderNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "1aa1620864174fbcbba8efdd17d9dd32"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension SSDMobilenetFeatureExtractor: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "688129c38f21456ebcb714abf9f89871"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

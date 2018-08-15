//
//  Models+Fritz.swift
//  Heartbeat
//
//  Created by Andrew Barba on 1/6/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//
import Fritz

extension MNIST: SwiftIdentifiedModel {
    static let modelIdentifier = "8cd3ee61b0d34b8e832977c0455d2d65"
    static let packagedModelVersion = 1
}

extension AgeNet: SwiftIdentifiedModel {
    static let modelIdentifier = "5b376c236b3b40e2826061218c682499"
    static let packagedModelVersion = 1
}

extension GenderNet: SwiftIdentifiedModel {
    static let modelIdentifier = "1aa1620864174fbcbba8efdd17d9dd32"
    static let packagedModelVersion = 1
}

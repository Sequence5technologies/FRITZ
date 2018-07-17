//
//  Models+Fritz.swift
//  Heartbeat
//
//  Created by Andrew Barba on 1/6/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//
import Fritz

extension MNIST: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-2"
}

extension AgeNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-3"
}

extension GenderNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-4"
}

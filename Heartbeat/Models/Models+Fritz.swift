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

    static let modelIdentifier: String = "324a6dfb5bf6409f8b2b47d928a32dd8"

    static let session = Fritz.Session(appToken: "ab85fe8881e5448d88f875ddc5ec8722", environment: Environment(namespace: "local", apiPath: "http://192.168.50.169:8070/sdk/v1"))
}

extension MNIST: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-2"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension AgeNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-3"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension GenderNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-4"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension SSDMobilenetFeatureExtractor: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-5"
    
    static let session = Fritz.Session(appToken: "app-token-12345")
}

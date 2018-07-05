//
//  SSDUtils.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 7/5/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import CoreML
import UIKit

struct BoundingBox {
    let yMin: Double
    let xMin: Double
    let yMax: Double
    let xMax: Double
    let imgHeight = 300.0
    let imgWidth = 300.0

    init(yMin: Double, xMin: Double, yMax: Double, xMax: Double) {
        self.yMin = yMin
        self.xMin = xMin
        self.yMax = yMax
        self.xMax = xMax
    }

    init(fromAnchor: [Float32]) {
        self.yMin = Double(fromAnchor[0])
        self.xMin = Double(fromAnchor[1])
        self.yMax = Double(fromAnchor[2])
        self.xMax = Double(fromAnchor[3])
    }

    init(fromAnchor anchor: Anchor) {
        self.yMin = anchor.yMin
        self.yMax = anchor.yMax
        self.xMin = anchor.xMin
        self.xMax = anchor.xMax
    }

    // Transposes to image height and width
    func toCGRect() -> CGRect {
        let height = imgHeight * (yMax - yMin)
        let width = imgWidth * (xMax - xMin)

        return CGRect(x: imgWidth * xMin, y: imgHeight * yMin, width: width, height: height)
    }

    // Transposes coordinates to image with given h/w and offset.
    func toCGRect(imgWidth:Double, imgHeight:Double, xOffset:Double, yOffset:Double) -> CGRect {
        let height = imgHeight * (yMax - yMin)
        let width = imgWidth * (xMax - xMin)

        return CGRect(x: imgWidth * xMin + xOffset, y: imgHeight * yMin + yOffset, width: width, height: height)
    }
}

struct AnchorEncoding {
    let ty: Double
    let tx: Double
    let th: Double
    let tw: Double
}

struct Prediction {
    let Y_SCALE = 10.0
    let X_SCALE = 10.0
    let H_SCALE = 5.0
    let W_SCALE = 5.0
    let index: Int
    let score: Double
    let anchor: Anchor
    let anchorEncoding: AnchorEncoding
    let detectedClass: Int
    let detectedClassLabel: String?

    var transformedBox: BoundingBox {
        get {
            let yCenter = anchorEncoding.ty / Y_SCALE * anchor.height + anchor.yCenter
            let xCenter = anchorEncoding.tx / X_SCALE * anchor.width + anchor.xCenter
            let h = exp(anchorEncoding.th / H_SCALE) * anchor.height
            let w = exp(anchorEncoding.tw / W_SCALE) * anchor.width

            let yMin = yCenter - h / 2.0
            let xMin = xCenter - w / 2.0
            let yMax = yCenter + h / 2.0
            let xMax = xCenter + w / 2.0

            return BoundingBox(yMin: yMin, xMin: xMin, yMax: yMax, xMax: xMax)
        }
    }
}


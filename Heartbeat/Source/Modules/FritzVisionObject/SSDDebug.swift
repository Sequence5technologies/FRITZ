//
//  SSDDebug.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 7/5/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import CoreML
import UIKit

class TestUIImages {

    private class func blankImage(with color: UIColor, height: Int, width: Int) -> UIImage? {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 300, height: 300))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(color.cgColor)
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    class func whiteImage(height: Int, width: Int) -> UIImage? {
        return blankImage(with: UIColor.white, height: height, width: width)
    }

    class func blackImage(height: Int, width: Int) -> UIImage? {
        return blankImage(with: UIColor.black, height: height, width: width)
    }
}

extension Array where Element == Prediction {

    func printPredictions() {
        if (self.count == 0) {
            return
        }
        print("Total Predictions: \(self.count)")
        print("Top 20 Predictions")
        for prediction in self {
            print("\(prediction.detectedClass) - \(prediction.detectedClassLabel!): \(prediction.score)")
        }
    }

}



class DebugUtils {
    let boxPredictions: MultiArray<Double>
    let classPredictions: MultiArray<Double>
    let numClasses: Int
    let numAnchors: Int
    let startIndex: Int
    // [4, 1917, 1]
    // [1, 1, 91, 1, 1917]


    init(boxPredictions: MLMultiArray, classPredictions: MLMultiArray, numClasses: Int, numAnchors: Int, skipFirst: Bool = true) {
        self.boxPredictions = MultiArray<Double>(boxPredictions)
        self.classPredictions = MultiArray<Double>(classPredictions)
        self.numAnchors = numAnchors
        self.numClasses = numClasses
        self.startIndex = skipFirst ? 1 : 0
        print(self.boxPredictions.shape)
        print(self.classPredictions.shape)
    }

    func classPredictions(_ classIndex: Int) -> Array<Double> {
        var baseShapeIndex: [Int] = []
        for shapeVar in self.classPredictions.shape {
            if shapeVar == 1 {
                baseShapeIndex.append(0)
            } else {
            }

        }
        let pointer = self.classPredictions.pointer.advanced(by: (classIndex) * self.numAnchors)
        return Array(UnsafeBufferPointer(start: pointer, count: self.numAnchors))
    }

    func maxValuePerClass() -> [Double] {
        print("donnne")
        var maxValues: [Double] = []

        for i in startIndex...(numClasses) {
            let preds = classPredictions(i)
            maxValues.append(preds.max()!)
        }

        return maxValues
    }
}

class DebugPrint {
    var lastDebugPrint: Int
    static let instance = DebugPrint()
    static let PRINT_DELTA = 5

    init() {
        lastDebugPrint = DebugPrint.time()
    }

    static func time() -> Int {
        return Int(DispatchTime.now().uptimeNanoseconds / UInt64(1e9))
    }

    static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let lastPrint = DebugPrint.instance.lastDebugPrint
        if time() - lastPrint < PRINT_DELTA {
            return
        }
        let output = items.map { "*\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
        DebugPrint.instance.lastDebugPrint = time()
    }
}

extension BoundingBox {
    static func oneByOneBox() -> BoundingBox {
        return BoundingBox(yMin: 0.0, xMin: 0.0, yMax: 1.0, xMax: 1.0)
    }
}


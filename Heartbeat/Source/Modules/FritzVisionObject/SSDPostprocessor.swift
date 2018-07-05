import CoreML
import UIKit

let LABELS: [Int: String] = [
    1: "person",
    2: "bicycle",
    3: "car",
    4: "motorcycle",
    5: "airplane",
    6: "bus",
    7: "train",
    8: "truck",
    9: "boat",
    10: "traffic light",
    11: "fire hydrant",
    13: "stop sign",
    14: "parking meter",
    15: "bench",
    16: "bird",
    17: "cat",
    18: "dog",
    19: "horse",
    20: "sheep",
    21: "cow",
    22: "elephant",
    23: "bear",
    24: "zebra",
    25: "giraffe",
    27: "backpack",
    28: "umbrella",
    31: "handbag",
    32: "tie",
    33: "suitcase",
    34: "frisbee",
    35: "skis",
    36: "snowboard",
    37: "sports ball",
    38: "kite",
    39: "baseball bat",
    40: "baseball glove",
    41: "skateboard",
    42: "surfboard",
    43: "tennis racket",
    44: "bottle",
    46: "wine glass",
    47: "cup",
    48: "fork",
    49: "knife",
    50: "spoon",
    51: "bowl",
    52: "banana",
    53: "apple",
    54: "sandwich",
    55: "orange",
    56: "broccoli",
    57: "carrot",
    58: "hot dog",
    59: "pizza",
    60: "donut",
    61: "cake",
    62: "chair",
    63: "couch",
    64: "potted plant",
    65: "bed",
    67: "dining table",
    70: "toilet",
    72: "tv",
    73: "laptop",
    74: "mouse",
    75: "remote",
    76: "keyboard",
    77: "cell phone",
    78: "microwave",
    79: "oven",
    80: "toaster",
    81: "sink",
    82: "refrigerator",
    84: "book",
    85: "clock",
    86: "vase",
    87: "scissors",
    88: "teddy bear",
    89: "hair drier",
    90: "toothbrush"
]



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


extension Array where Element == Prediction {

    func printPredictions() {
        if (self.count == 0) {
            return
        }
        print("Total Predictions: \(self.count)")
        print("Top 20 Predictions")
        for prediction in self {
            print("\(prediction.detectedClass) - \(prediction.detectedClassLabel!): \(prediction.score) \(prediction.transformedBox)")
        }
    }

}
class SSDPostProcessor {
    let numAnchors: Int = 1917
    let numClasses: Int = 90
    var threshold: Double
    let classNames: [Int: String] = LABELS
    let personClass = 1


    init(threshold: Double = 0.01) {
        self.threshold = threshold
    }
    
    func postprocess(boxPredictions: MLMultiArray, classPredictions: MLMultiArray) -> [Prediction] {
        let summary = DebugUtils(boxPredictions: boxPredictions, classPredictions: classPredictions, numClasses: 90, numAnchors: 1917)
        print("Max value per class \(summary.maxValuePerClass())")
        let prunedPredictions = pruneLowScoring(boxPredictions: boxPredictions, classPredictions: classPredictions)
        
        let finalPredictions = nonMaximumSupression(predictions: prunedPredictions)
        return finalPredictions
    }
    
    private func nonMaximumSupression(predictions: [[Prediction]]) -> [Prediction] {
        var finalPredictions: [Prediction] = []
        
        for klass in 1...numClasses {
            let predictionsForClass = predictions[klass]
            let supressedPredictions = nonMaximumSupressionForClass(predictions: predictionsForClass, iouThreshold: 0.3, maxBoxes: 10)

            finalPredictions.append(contentsOf: supressedPredictions)
        }
        
        return finalPredictions.sorted(by: { return $0.score > $1.score })
    }
    
    private func nonMaximumSupressionForClass(predictions: [Prediction],
                                              iouThreshold: Float,
                                              maxBoxes: Int) -> [Prediction] {

        // Sort the boxes based on their confidence scores, from high to low.
        let sortedPredictions = predictions.sorted { $0.score > $1.score }
        
        var selectedPredictions: [Prediction] = []
        
        // Loop through the bounding boxes, from highest score to lowest score,
        // and determine whether or not to keep each box.
        for boxA in sortedPredictions {
            if selectedPredictions.count >= maxBoxes { break }
            
            var shouldSelect = true
            
            // Does the current box overlap one of the selected boxes more than the
            // given threshold amount? Then it's too similar, so don't keep it.
            for boxB in selectedPredictions {
                let iou = IOU(boxA.transformedBox.toCGRect(), boxB.transformedBox.toCGRect())
                if iou > iouThreshold {
                    shouldSelect = false
                    break
                }
            }
            
            // This bounding box did not overlap too much with any previously selected
            // bounding box, so we'll keep it.
            if shouldSelect {
                selectedPredictions.append(boxA)
            }
        }
        
        return selectedPredictions
    }

    func sigmoid(_ val:Double) -> Double {
        return 1.0/(1.0 + exp(-val))
    }

    private func pruneLowScoring(boxPredictions: MLMultiArray, classPredictions: MLMultiArray) -> [[Prediction]] {
        var prunedPredictions: [[Prediction]] = Array(repeating: [], count: numClasses + 1)
        // let klass = personClass
        for klass in 1...numClasses {
        // for klass in [personClass] { // 1...numClasses {
        for box in 0...(numAnchors - 1) {
            let score = classPredictions[offset(klass, box)].doubleValue
            if score > threshold {
                let classLabel = classNames[klass]
                let anchorEncoding = AnchorEncoding(
                    ty: boxPredictions[offset(0, box)].doubleValue,
                    tx: boxPredictions[offset(1, box)].doubleValue,
                    th: boxPredictions[offset(2, box)].doubleValue,
                    tw: boxPredictions[offset(3, box)].doubleValue
                )

                let prediction = Prediction(index: box, score: score, anchor: Anchors.ssdAnchors[box], anchorEncoding: anchorEncoding, detectedClass: klass, detectedClassLabel: classLabel)

                prunedPredictions[klass].append(prediction)
            }

            }
        }
        
        return prunedPredictions
    }
    
    private func offset(_ i: Int, _ j: Int) -> Int {
        return i * numAnchors + j
    }
}


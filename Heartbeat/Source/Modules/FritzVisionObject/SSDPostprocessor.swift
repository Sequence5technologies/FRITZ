import CoreML
import UIKit


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
//        let summary = DebugUtils(boxPredictions: boxPredictions, classPredictions: classPredictions, numClasses: 90, numAnchors: 1917)
        let prunedPredictions = pruneLowScoring(boxPredictions: boxPredictions, classPredictions: classPredictions)
        // prunedPredictions.printPredictions()
        let finalPredictions = nonMaximumSupression(predictions: prunedPredictions, iouThreshold: 0.3, maxBoxes: 100)

        return finalPredictions
    }
    
    private func nonMaximumSupression(predictions: [Prediction],
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

    func sigmoid(_ val: Double) -> Double {
        return 1.0 / (1.0 + exp(-val))
    }

    private func pruneLowScoring(boxPredictions: MLMultiArray, classPredictions: MLMultiArray) -> [Prediction] {
        var prunedPredictions: [Prediction] = []
        var classIndexes: [Double] = []
        for boxIdx in 0..<numAnchors {
            var maxScore = 0.0
            var maxIndex = -1

            for classIdx in 1...numClasses {
                let score = sigmoid(classPredictions[offset(classIdx, boxIdx)].doubleValue)
                if classIdx == 1 {
                    classIndexes.append(classPredictions[offset(classIdx, boxIdx)].doubleValue)
                }
                if (score >= maxScore) {
                    maxScore = score
                    maxIndex = classIdx
                }
            }
            if maxScore < 0.51 {
                continue
            }
            let classLabel = classNames[maxIndex]
            let anchorEncoding = AnchorEncoding(
                ty: boxPredictions[offset(0, boxIdx)].doubleValue,
                tx: boxPredictions[offset(1, boxIdx)].doubleValue,
                th: boxPredictions[offset(2, boxIdx)].doubleValue,
                tw: boxPredictions[offset(3, boxIdx)].doubleValue
            )

            let prediction = Prediction(index: boxIdx, score: maxScore, anchor: Anchors.ssdAnchors[boxIdx], anchorEncoding: anchorEncoding, detectedClass: maxIndex, detectedClassLabel: classLabel)
            prunedPredictions.append(prediction)
        }
        return prunedPredictions
    }

    private func offset(_ i: Int, _ j: Int) -> Int {
        return i * numAnchors + j
    }
}


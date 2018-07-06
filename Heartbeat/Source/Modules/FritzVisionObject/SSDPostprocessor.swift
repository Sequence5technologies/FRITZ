import CoreML
import UIKit



class DebugTimer {

    let startTime: UInt64
    init() {
        startTime = DispatchTime.now().uptimeNanoseconds
    }

    func elapsed() -> Double {
        return Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1e9
    }
}

class SSDPostProcessor {
    let numAnchors: Int = 1917
    let numClasses: Int = 90
    let threshold: Double
    let iouThreshold: Float

    let classNames: [Int: String] = LABELS

    init(threshold: Double = 0.6, iouThreshold: Float = 0.25) {
        self.threshold = threshold
        self.iouThreshold = iouThreshold
    }
    
    func postprocess(boxPredictions: MLMultiArray, classPredictions: MLMultiArray) -> [Prediction] {
        let prunedPredictions = pruneLowScoring(boxPredictions: boxPredictions, classPredictions: classPredictions)
        let finalPredictions = nonMaximumSupression(predictions: prunedPredictions)
        return finalPredictions
    }

    private func nonMaximumSupression(predictions: [[Prediction]]) -> [Prediction] {
        var finalPredictions: [Prediction] = []

        for klass in 1...numClasses {
            let predictionsForClass = predictions[klass]

            let supressedPredictions = nonMaximumSupressionForClass(predictions: predictionsForClass, iouThreshold: iouThreshold, maxBoxes: 100)

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
                if IOU(boxA.transformedBox.toCGRect(), boxB.transformedBox.toCGRect()) > iouThreshold {
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

    private func pruneLowScoring(boxPredictions: MLMultiArray, classPredictions: MLMultiArray) -> [[Prediction]] {
        var prunedPredictionsByClass: [[Prediction]] = Array(repeating: [], count: numClasses + 1)
        for boxIdx in 0..<numAnchors {
            var maxScore = 0.0
            var maxIndex = -1

            for classIdx in 1...numClasses {
                let score = sigmoid(classPredictions[offset(classIdx, boxIdx)].doubleValue)
                if score < threshold {
                    continue
                }
                if (score >= maxScore) {
                    maxScore = score
                    maxIndex = classIdx
                }
            }

            if maxIndex == -1 {
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
            prunedPredictionsByClass[maxIndex].append(prediction)
        }
        return prunedPredictionsByClass
    }

    private func offset(_ i: Int, _ j: Int) -> Int {
        return i * numAnchors + j
    }
}


//
//  FritzVisionObject.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 6/29/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import Vision
import AVFoundation
import FritzVision

public typealias FritzVisionObjectCallback = ([FritzVisionObject]?, Error?) -> Void


public class FritzVisionObject {
    let label: FritzVisionLabel
    let boundingBox: BoundingBox

    init(label: FritzVisionLabel, boundingBox: BoundingBox) {
        self.label = label
        self.boundingBox = boundingBox
    }
}

class FritzVisionObjectModel {

    let model = ssdlite_mobilenet_v2_coco().model
    // let model = SSDMobilenetFeatureExtractor().model
    let ssdPostProcessor = SSDPostProcessor()
    let semaphore = DispatchSemaphore(value: 1)

    let visionModel: VNCoreMLModel
    init() {
        guard let visionModel = try? VNCoreMLModel(for: model)
            else { fatalError("Can't load VisionML model") }
        self.visionModel = visionModel
    }

    func processClassifications(for request: VNRequest, error: Error?) -> [Prediction]? {
        guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
            return nil
        }
        guard results.count == 2 else {
            return nil
        }
        guard let boxPredictions = results[0].featureValue.multiArrayValue,
            let classPredictions = results[1].featureValue.multiArrayValue else {
                return nil
        }
        let classPreds = MultiArray<Double>(classPredictions)
        let predictions = self.ssdPostProcessor.postprocess(boxPredictions: boxPredictions, classPredictions: classPredictions)
        return predictions
    }

    func predict(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation, options: [VNImageOption : Any], completion: @escaping FritzVisionObjectCallback) {

        let trackingRequest = VNCoreMLRequest(model: visionModel) { (request, error) in
            guard let predictions = self.processClassifications(for: request, error: error) else {
                completion(nil, error)
                return
            }
            let fritzObjects: [FritzVisionObject] = predictions.map { value in
                FritzVisionObject(label: FritzVisionLabel(label: value.detectedClassLabel!, confidence: value.score), boundingBox: value.transformedBox)
            }
            completion(fritzObjects, nil)

            self.semaphore.signal()
        }
        trackingRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop

        self.semaphore.wait()
        do {

            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: options)
            let t = DebugTimer()
            try imageRequestHandler.perform([trackingRequest])
            print(t.elapsed())
        } catch {
            print(error)
            self.semaphore.signal()
        }
    }
}


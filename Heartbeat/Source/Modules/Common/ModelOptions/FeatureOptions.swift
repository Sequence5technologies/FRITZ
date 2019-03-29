//
//  FeatureOptions.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 3/7/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation


enum CellType {
    case rangeValue
    case segmentValue
}


/// Various Model Configuration parameters.
enum ConfigurableOptionType {
    // These are global to all models, if you want to add a new one, just add a new case here.
    case minThreshold
    case alpha
    case modelResolution
    case numPoses
    case minPoseThreshold
    case minPartThreshold

    func getName() -> String{
        switch self {
        case .minThreshold: return "Min Threshold"
        case .alpha: return "Alpha"
        case .modelResolution: return "Model Resolution"
        case .numPoses: return "Number of Poses"
        case .minPartThreshold: return "Min Part Threshold"
        case .minPoseThreshold: return "Min pose Threshold"
        }
    }
}


protocol FeatureOption {
    static var cellType: CellType { get }
    var optionType: ConfigurableOptionType { get }
}


protocol FeatureOptionCellDelegate: class {
    func update(_ value: FeatureOption)
}


/// Represent a range of values
struct RangeValue: FeatureOption {
    static let cellType: CellType = .rangeValue

    let optionType: ConfigurableOptionType
    let min: Float
    let max: Float
    var value: Float
}


/// Represent distinct values.
struct SegmentValue: FeatureOption {
    static let cellType: CellType = .segmentValue

    let optionType: ConfigurableOptionType
    let options: [String]
    var selectedIndex: Int
}

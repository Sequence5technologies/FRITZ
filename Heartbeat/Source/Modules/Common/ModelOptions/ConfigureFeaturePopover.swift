//
//  ConfigureModelPopover.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 3/6/19.
//  Copyright © 2019 Fritz Labs, Inc. All rights reserved.
//

import Foundation
import UIKit


protocol ChooseFeatureDelegate: class {

    func chooseFeature<T: HeartbeatFeature>(_ feature: T)
}


class ConfigureFeaturePopoverViewController<Feature: HeartbeatFeature>: UITableViewController, FeatureOptionCellDelegate, ChooseFeatureDelegate {

    func chooseFeature<T>(_ feature: T) where T : HeartbeatFeature {
        self.selectedFeature = (feature as! Feature)
        self.options = feature.options
        self.optionsList = feature.options.values.map { $0 }
    }


    public var models: [FritzModel]!

    public var selectedFeature: Feature?

    @IBAction func unwindWithSelectedRow(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    var options: ConfigurableOptions!

    private var optionsList: [FeatureOption]!

    private func getOption(for section: Int) -> FeatureOption {
        return optionsList[section - 1]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(ChooseModelCell.nib, forCellReuseIdentifier: ChooseModelCell.identifier)
        tableView.register(RangeSliderCell.nib, forCellReuseIdentifier: RangeSliderCell.identifier)
        tableView.register(SegmentSliderCell.nib, forCellReuseIdentifier: SegmentSliderCell.identifier)
        optionsList = options.values.map { $0 }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChooseModel" {
            let modelSelectionViewController = segue.destination as! ChooseModelTableViewController<Feature>
            modelSelectionViewController.models = models
            modelSelectionViewController.delegate = self
            modelSelectionViewController.selectedModel = selectedFeature?.fritzModel
            return
        }
    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {

        if section == 0 {
            return "Model Name"
        }
        return getOption(for: section).optionType.getName()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + optionsList.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChooseModelCell.identifier) as! ChooseModelCell
            if let name = selectedFeature?.fritzModel.name {
                cell.textLabel?.text = name
            } else {
                cell.textLabel?.text = "Choose a model"

            }
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        let option = getOption(for: indexPath.section)

        switch type(of: option).cellType {
        case .rangeValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: RangeSliderCell.identifier) as! RangeSliderCell
            cell.name = option.optionType.getName()
            cell.delegate = self
            cell.value = (option as! RangeValue)
            cell.initLabels()
            return cell
        case .segmentValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: SegmentSliderCell.identifier) as! SegmentSliderCell
            cell.name = option.optionType.getName()
            cell.delegate = self
            cell.value = (option as! SegmentValue)
            cell.initSegments()
            return cell
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            // Segue to the second view controller
            self.performSegue(withIdentifier: "ChooseModel", sender: self)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func update(_ value: FeatureOption) {
        options[value.optionType] = value
        selectedFeature?.options[value.optionType] = value
    }

}

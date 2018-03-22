//
//  NavigationController.swift
//  Heartbeat
//
//  Created by Andrew Barba on 12/14/17.
//  Copyright © 2017 Fritz Labs, Inc. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        let buttonFont = UIFont.systemFont(ofSize: 14, weight: .semibold)

        navigationBar.barTintColor = .black
        navigationBar.tintColor = .white

        navigationBar.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: UIColor.white
        ]

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
            .setTitleTextAttributes([ .font: buttonFont], for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
            .setTitleTextAttributes([ .font: buttonFont], for: .highlighted)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
            .setTitleTextAttributes([ .font: buttonFont], for: .disabled)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
            .setTitleTextAttributes([ .font: buttonFont], for: .selected)
    }
}

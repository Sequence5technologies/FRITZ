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

        navigationBar.barTintColor = .black
        navigationBar.tintColor = .white

        navigationBar.titleTextAttributes = [
            .font: UIFont(name: "AvenirNext-DemiBold", size: 17)!,
            .foregroundColor: UIColor.white
        ]
    }
}

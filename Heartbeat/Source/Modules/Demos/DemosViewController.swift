//
//  DemosViewController.swift
//  Heartbeat
//
//  Created by Andrew Barba on 12/26/17.
//  Copyright © 2017 Fritz Labs, Inc. All rights reserved.
//

import UIKit

class DemosViewController: UITableViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Fritz Demos"

        clearsSelectionOnViewWillAppear = true
    }
}

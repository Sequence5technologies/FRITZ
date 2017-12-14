//
//  ViewController.swift
//  Fritz Labs
//
//  Created by Andrew Barba on 12/12/17.
//  Copyright © 2017 Fritz Labs, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let theGreatWaveModel = TheGreatWave().fritz()

    let lightningsBelowTheSummitModel = LightningsBelowTheSummit().fritz()

    let mnistModel = MNIST().fritz()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

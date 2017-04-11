//
//  GraphViewController.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 4/11/17.
//  Copyright © 2017 Andrij Trubchanin. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    var graphFunction: String? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var graphView: GraphView!
    
    private func updateUI() {
        // set graphView API here
        graphView?.graphFunction = graphFunction
    }
}

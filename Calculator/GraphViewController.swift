//
//  GraphViewController.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 4/11/17.
//  Copyright © 2017 Andrij Trubchanin. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    // Model
    var graphFunction: ((Double) -> Double?)?
    
    // View
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
        }
    }
    
    // GraphViewDataSource
    func getValueFor(point x: CGFloat) -> CGFloat? {
        if let function = graphFunction,
           let result = function(Double(x)) {
            return CGFloat(result)
        }
        return nil
    }
}

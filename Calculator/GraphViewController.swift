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
            
            // restore saved parameters
            let defaults = UserDefaults.standard
            if let graphScale = defaults.object(forKey: "graphScale") as? CGFloat {
                graphView.scale = graphScale
            }
            if let graphOriginX = defaults.object(forKey: "graphOriginX") as? CGFloat,
               let graphOriginY = defaults.object(forKey: "graphOriginY") as? CGFloat {
                graphView.origin = CGPoint(x: graphOriginX, y: graphOriginY)
            }
            
            // add gestures
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView,
                action: #selector(GraphView.changeScale)
            ))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: graphView,
                action: #selector(GraphView.changeOrigin)
            ))

            let recognizer = UITapGestureRecognizer(target: graphView, action: #selector(GraphView.changeOrigin))
            recognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(recognizer)
        }
    }
    
    // GraphViewDataSource
    // return y for x
    func getValueFor(point x: CGFloat) -> CGFloat? {
        if let function = graphFunction,
           let result = function(Double(x)) {
            return CGFloat(result)
        }
        return nil
    }
    
    // save parameters
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(graphView.scale, forKey: "graphScale")
        defaults.set(graphView.origin.x, forKey: "graphOriginX")
        defaults.set(graphView.origin.y, forKey: "graphOriginY")
    }
}

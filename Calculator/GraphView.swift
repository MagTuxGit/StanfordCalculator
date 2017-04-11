//
//  GraphView.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 4/11/17.
//  Copyright © 2017 Andrij Trubchanin. All rights reserved.
//

import UIKit

class GraphView: UIView {

    @IBInspectable
    var scale: CGFloat = 1 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = .blue { didSet { setNeedsDisplay() } }
    
    var graphFunction: String? { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        color.set()
        let origin = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let axes = AxesDrawer()
        axes.drawAxes(in: bounds, origin: origin, pointsPerUnit: 10)
    }
}

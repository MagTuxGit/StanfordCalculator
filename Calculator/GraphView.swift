//
//  GraphView.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 4/11/17.
//  Copyright © 2017 Andrij Trubchanin. All rights reserved.
//

import UIKit

// data source protocol
protocol GraphViewDataSource {
    func getValueFor(point x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    // MARK: properties
    @IBInspectable
    var color: UIColor = .black { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 1 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var scale: CGFloat = 50 { didSet { setNeedsDisplay() } }

    var origin: CGPoint! { didSet { setNeedsDisplay() } }       // maybe CGPoint.zero ?
    var dataSource: GraphViewDataSource?
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scale *= recognizer.scale
            recognizer.scale  = 1
        default:
            break
        }
    }
    
    func changeOrigin(recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            if let panRecognizer = recognizer as? UIPanGestureRecognizer {
                let translation = panRecognizer.translation(in: self)
                origin = CGPoint(x: origin.x + translation.x, y: origin.y + translation.y)
                panRecognizer.setTranslation(CGPoint.zero, in: self)
            }
            if let tapRecognizer = recognizer as? UITapGestureRecognizer {
                origin = tapRecognizer.location(in: self)
            }
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        
        // draw axes
        let axes = AxesDrawer()
        axes.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        
        // draw graph
        if let data = dataSource {
            pathFor(data: data).stroke()
        }
    }
    
    private func pathFor(data: GraphViewDataSource) -> UIBezierPath {
        let path = UIBezierPath()
        
        var pathIsEmpty = true
        var point = CGPoint()
        
        // iterate over every point across the width of the view
        let width = Int(bounds.size.width)
        for pixel in 0...width {
            point.x = CGFloat(pixel)
            
            // scale points to units
            if let y = data.getValueFor(point: (point.x - origin.x) / scale) {
                
                // don't draw anything if value doesn't exist
                if !y.isNormal && !y.isZero {
                    pathIsEmpty = true
                    continue
                }
                
                // scale units to points
                point.y = origin.y - y * scale
                
                // just move if the previous point is not valid
                if pathIsEmpty {
                    path.move(to: point)
                    pathIsEmpty = false
                } else {
                    path.addLine(to: point)
                }
            }
        }
        path.lineWidth = lineWidth
        return path
    }
}

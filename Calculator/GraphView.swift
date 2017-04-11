//
//  GraphView.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 4/11/17.
//  Copyright © 2017 Andrij Trubchanin. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func getValueFor(point x: CGFloat) -> CGFloat?
}

class GraphView: UIView {
    var color: UIColor = .blue { didSet { setNeedsDisplay() } }
    var scale: CGFloat = 10 { didSet { setNeedsDisplay() } }
    var origin: CGPoint? { didSet { setNeedsDisplay() } }       // maybe CGPoint.zero ?
    var lineWidth: CGFloat = 1 { didSet { setNeedsDisplay() } }
    
    var dataSource: GraphViewDataSource?
    
    override func draw(_ rect: CGRect) {
        color.set()
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        
        let axes = AxesDrawer()
        axes.drawAxes(in: bounds, origin: origin!, pointsPerUnit: scale)
        
        if let data = dataSource {
            pathFor(data: data).stroke()
        }
    }
    
    private func pathFor(data: GraphViewDataSource) -> UIBezierPath {
        let path = UIBezierPath()
        
        var pathIsEmpty = true
        var point = CGPoint()
        
        let width = Int(bounds.size.width * scale)
        for pixel in 0...width {
            point.x = CGFloat(pixel) / scale
            
            if let y = data.getValueFor(point: (point.x - origin!.x) / scale) {
                
                if !y.isNormal && !y.isZero {
                    pathIsEmpty = true
                    continue
                }
                
                point.y = origin!.y - y * scale
                
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

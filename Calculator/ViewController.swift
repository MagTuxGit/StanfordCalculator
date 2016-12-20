//
//  ViewController.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 12/12/16.
//  Copyright © 2016 Andrij Trubchanin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    
    private var isInTheMiddleOfTheTyping = false
    
    override func viewDidLoad() {
        display.layer.borderWidth = 1.0
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if isInTheMiddleOfTheTyping {
            display.text = display.text!+digit
        } else {
            display.text = digit
        }
        isInTheMiddleOfTheTyping = true
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalcBrains()
    
    var savedProgram: CalcBrains.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        brain.setOperand(operand: displayValue)
        isInTheMiddleOfTheTyping = false
        if let operationSymbol = sender.currentTitle {
            brain.performOperation(symbol: operationSymbol)
            displayValue = brain.result

            /*
             if operationSymbol=="π" {
                 //display.text = String(M_PI)
                 displayValue = M_PI
             } else if operationSymbol=="√" {
                 displayValue = sqrt(displayValue)
             }
             */
        }
    }
}

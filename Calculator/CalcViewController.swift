//
//  CalcViewController.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 12/12/16.
//  Copyright © 2016 Andrij Trubchanin. All rights reserved.
//

import UIKit

class CalcViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    
    private var isInTheMiddleOfTheTyping = false {
        willSet {
            // reset dot when reseting typing
            if !newValue { isDotPresent = false }
        }
    }
    private var isDotPresent = false
    
    override func viewDidLoad() {
        display.layer.borderWidth = 1.0
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        var digit = sender.currentTitle!
        if isInTheMiddleOfTheTyping && display.text! != "0"{
            // ignore if dot touched and dot is already present
            if digit == "." {
                digit = isDotPresent ? "" : digit
                isDotPresent = true
            }
            display.text = display.text!+digit
        } else {
            // add zero if dot is the first digit
            if digit=="." {
                display.text = "0."
                isDotPresent = true
            }
            else {
                display.text = digit
            }
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
    
    @IBAction func backspace(_ sender: UIButton) {
        var text = display.text!
        let delChar = text.remove(at: text.index(before: text.endIndex))
        if delChar == "." {
            isDotPresent = false
        }
        if text.isEmpty || text == "-" { text = "0" }
        display.text = text
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

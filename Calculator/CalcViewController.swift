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
    @IBOutlet weak var history: UILabel!
    
    private var isInTheMiddleOfTheTyping = false
    
    override func viewDidLoad() {
        display.layer.borderWidth = 1.0
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        // clear state when new expression starts
        if !brain.isPartialResult && !isInTheMiddleOfTheTyping {
            brain.clear()
            history.text = "..."
        }

        let digit = sender.currentTitle!

        if isInTheMiddleOfTheTyping && display.text! != "0" {
            // ignore if dot touched and dot is already present
            if (digit != ".") || (display.text!.range(of: ".")==nil) {
                display.text = display.text!+digit
            }
        } else {
            display.text = (digit == ".") ? "0." : digit
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
        if !isInTheMiddleOfTheTyping { return }     // don't use backspace on results or constants
        var text = display.text!
        text.remove(at: text.index(before: text.endIndex))
        if text.isEmpty || (text == "-") { text = "0" }
        display.text = text
    }
    
    @IBAction func clear(_ sender: UIButton) {
        display.text = "0"
        history.text = "..."
        isInTheMiddleOfTheTyping = false
        brain.clear()
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
        history.text = brain.description + brain.lastOperand + (brain.isPartialResult || brain.description.isEmpty ? "..." : "=")
    }
}

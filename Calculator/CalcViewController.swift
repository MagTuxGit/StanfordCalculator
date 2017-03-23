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
    @IBOutlet private weak var history: UILabel!
    
    // buttons outlets for text manipulations
    @IBOutlet private weak var btnRand: UIButton!
    @IBOutlet private weak var btnRest: UIButton!
    @IBOutlet private weak var btnSave: UIButton!
    
    private var isInTheMiddleOfTheTyping = false
    
    let formatter = DefaultNumberFormatter()
    
    override func viewDidLoad() {
        display.layer.borderWidth = 1.0
        btnRand.titleLabel!.adjustsFontSizeToFitWidth = true
        btnRest.titleLabel!.adjustsFontSizeToFitWidth = true
        btnSave.titleLabel!.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        // clear state when new expression starts
        if !brain.resultIsPending && !isInTheMiddleOfTheTyping {
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
            if let dValue = Double(display.text!) {
                return dValue
            }
            return 0
        }
        set {
            display.text = formatter.string(from: NSNumber(value: newValue))
        }
    }
    
    private var brain = CalcBrains()
    
    private var savedProgram: CalcBrains.PropertyList?
    
    @IBAction private func performOperation(_ sender: UIButton) {
        brain.setOperand(displayValue)
        isInTheMiddleOfTheTyping = false
        if let operationSymbol = sender.currentTitle {
            brain.performOperation(operationSymbol)
            if let result = brain.result {
                displayValue = result
            }

            /*
             if operationSymbol=="π" {
                 //display.text = String(M_PI)
                 displayValue = M_PI
             } else if operationSymbol=="√" {
                 displayValue = sqrt(displayValue)
             }
             */
        }
        setHistory()
    }
    
    private func setHistory() {
        history.text = brain.description + (brain.resultIsPending || brain.description.isEmpty ? "..." : "=")
    }
    
    // MARK: Additional buttons actions
    @IBAction private func save() {
        savedProgram = brain.program
    }
    
    @IBAction private func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            if let result = brain.result {
                displayValue = result
            }
        }
    }
    
    @IBAction private func backspace(_ sender: UIButton) {
        if !isInTheMiddleOfTheTyping { return }     // don't use backspace on results or constants
        var text = display.text!
        text.remove(at: text.index(before: text.endIndex))
        if text.isEmpty || (text == "-") { text = "0" }
        display.text = text
    }
    
    @IBAction private func clear(_ sender: UIButton) {
        display.text = "0"
        history.text = "..."
        isInTheMiddleOfTheTyping = false
        brain.clear()
    }

    @IBAction func popM(_ sender: UIButton) {
    }
    
    @IBAction func pushM(_ sender: UIButton) {
    }
    
}

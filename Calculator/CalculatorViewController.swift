//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 12/12/16.
//  Copyright © 2016 Andrij Trubchanin. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
    // MARK: outlets and vars
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var history: UILabel!
    @IBOutlet private weak var memory: UILabel!
    @IBOutlet private weak var btnRand: UIButton!
    
    private var isInTheMiddleOfTheTyping = false
    
    private let formatter = DefaultNumberFormatter()
    
    // MARK: predefined
    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }

    override func viewDidLoad() {
        display.layer.borderWidth = 1.0
        btnRand.titleLabel!.adjustsFontSizeToFitWidth = true
        updateUI()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // don't show any graph if the result is pending
        if identifier == "showGraph" {
            if brain.evaluate().isPending || brain.evaluate().result == nil {
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination.contents
        if let graphVC = destinationVC as? GraphViewController {
            // don't show any graph if the result is pending
            if brain.evaluate().isPending {
                return
            }
            // set graph model
            graphVC.graphFunction = { [weak self] (x: Double) -> Double? in
                return self?.brain.evaluate(using: ["M":x]).result
            }
            graphVC.navigationItem.title = brain.description
        }
    }
    
    // don't collapse the empty graph VC onto the calculator
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contents == self {
            if let graphVC = secondaryViewController.contents as? GraphViewController, graphVC.graphFunction == nil {
                // I say I want to collapse it but I don't do it really, so no collapse happens
                return true
            }
        }
        return false
    }

    // MARK: Calculator actions
    @IBAction private func touchDigit(_ sender: UIButton) {
        // clear state when new expression starts
//        if !brain.resultIsPending && !isInTheMiddleOfTheTyping {
//            brain.clear()
//            history.text = "..."
//        }

        let digit = sender.currentTitle!

        if isInTheMiddleOfTheTyping && display.text! != "0" {
            // ignore if dot touched and dot is already present
            if (digit != ".") || (!display.text!.contains(".")) {
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
    
    //private var savedProgram: CalcBrains.PropertyList?
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if isInTheMiddleOfTheTyping {
            brain.setOperand(displayValue)
        }
        isInTheMiddleOfTheTyping = false
        if let operationSymbol = sender.currentTitle {
            brain.performOperation(operationSymbol)
            //if let result = brain.result {
            if let result = brain.evaluate(using: variableNames).result {
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
        updateUI()
    }
    
    private func updateUI() {
        history.text = brain.description + (brain.resultIsPending || brain.description == " " ? "..." : "=")
        
        if let variableValue = variableNames["M"] {
            let mValue = formatter.string(from: NSNumber(value: variableValue)) ?? ""
            memory.text! = "M = " + mValue
        } else {
            memory.text! = "M isn't set"
        }
    }
    
    // MARK: Additional buttons actions
//    @IBAction private func save() {
//        savedProgram = brain.program
//    }
//    
//    @IBAction private func restore() {
//        if savedProgram != nil {
//            brain.program = savedProgram!
//            if let result = brain.result {
//                displayValue = result
//                setHistory()
//            }
//        }
//    }
    
    @IBAction private func backspace(_ sender: UIButton) {
        if !isInTheMiddleOfTheTyping {
            brain.undo()
            if let result = brain.evaluate(using: variableNames).result {
                displayValue = result
            }
            updateUI()
            return
        }
        
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
        variableNames.removeAll()
        updateUI()
    }

    private var variableNames: Dictionary<String, Double> = [:]

    @IBAction private func popM(_ sender: UIButton) {
        brain.setOperand(variableName: "M")
        isInTheMiddleOfTheTyping = false
        if let result = brain.evaluate(using: variableNames).result {
            displayValue = result
        }
        updateUI()
    }
    
    @IBAction private func pushM(_ sender: UIButton) {
        variableNames["M"] = displayValue
        isInTheMiddleOfTheTyping = false
        if let result = brain.evaluate(using: variableNames).result {
            displayValue = result
        }
        updateUI()
    }
}

extension UIViewController {
    var contents: UIViewController {
        if let navigationVC = self as? UINavigationController {
            return navigationVC.visibleViewController ?? self
        }
        return self
    }
}

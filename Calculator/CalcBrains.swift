//
//  CalcBrains.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 12/13/16.
//  Copyright © 2016 Andrij Trubchanin. All rights reserved.
//
// description implementation was taken here https://github.com/m2mtech/calculator-2016

import Foundation

// just in case, not used
func factorial(_ op1: Double) -> Double {
    if (op1 <= 1) {
        return 1
    }
    return op1 * factorial(op1 - 1.0)
}

class CalcBrains {
    // MARK: Operation section
    private var accumulator = 0.0
    
    let formatter = DefaultNumberFormatter()

    func setOperand (operand : Double) {
        accumulator = operand
        // desc acc can be a symbol of a constant
        if descriptionAccumulator == " " {
            descriptionAccumulator = formatter.string(from: NSNumber(value: accumulator)) ?? ""
        }
        internalProgram.append(operand)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOp(sqrt, { "√(" + $0 + ")" }),
        "cos" : Operation.UnaryOp(cos, { "cos(" + $0 + ")" }),
        "sin" : Operation.UnaryOp(sin, { "sin(" + $0 + ")" }),
        "tan" : Operation.UnaryOp(tan, { "tan(" + $0 + ")" }),
        "ln" : Operation.UnaryOp(log, { "ln(" + $0 + ")" }),
        "+/-" : Operation.UnaryOp({ -$0 },{ "-(" + $0 + ")" }),
        "x⁻¹" : Operation.UnaryOp({ 1.0/$0 }, { "1/(" + $0 + ")" }),
        "x²" : Operation.UnaryOp({ $0*$0 }, { "(" + $0 + ")²" }),
        "eˣ" : Operation.UnaryOp({ pow(M_E, $0) }, { "e^" + $0 }),
        //"×" : Operation.BinaryOp(multiply),
        //"×" : Operation.BinaryOp({ $0 * $1 }),
        //"÷" : Operation.BinaryOp({ $0 / $1 }),
        //"+" : Operation.BinaryOp({ $0 + $1 }),
        //"−" : Operation.BinaryOp({ $0 - $1 }),
        "×" : Operation.BinaryOp(*, { $0 + " × " + $1 }, 1),
        "÷" : Operation.BinaryOp(/, { $0 + " ÷ " + $1 }, 1),
        "+" : Operation.BinaryOp(+, { $0 + " + " + $1 }, 0),
        "−" : Operation.BinaryOp(-, { $0 + " - " + $1 }, 0),
        "xʸ": Operation.BinaryOp(pow, { $0 + " ^ " + $1 }, 2),
        "=" : Operation.Equals,
        "Rand": Operation.Random({ Double(arc4random()) / Double(UINT32_MAX) }),
        // not used
        "asin" : Operation.UnaryOp(asin, { "asin(" + $0 + ")"}),
        "acos" : Operation.UnaryOp(acos, { "acos(" + $0 + ")"}),
        "atan" : Operation.UnaryOp(atan, { "atan(" + $0 + ")"})
    ]
        
    private enum Operation {
        case Constant(Double)
        case UnaryOp((Double) -> Double, (String) -> String)
        case BinaryOp((Double,Double) -> Double, (String,String) -> String, Int)
        case Equals
        case Random(() -> Double)
    }
    
    func performOperation (symbol: String) {
        internalProgram.append(symbol)
        
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value) :
                //if !isPartialResult { clear() }     // clear state when new expression starts
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOp(let function, let descriptionFunction) :
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOp(let function, let descriptionFunction, let precedence) :
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator,
                                                   descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                // desc acc should contain last operand only
                descriptionAccumulator = " "
            case .Equals :
                executePendingBinaryOperation()
            case .Random(let random) :
                accumulator = random()
                descriptionAccumulator = "rand()"
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        descriptionAccumulator = " "
        currentPrecedence = Int.max
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    // MARK: Variables section
    var variableNames: Dictionary<String, Double> = [:]
    
    func setOperand(variableName: String) {
        if let variableValue = variableNames[variableName] {
            setOperand(operand: variableValue)
        } else {
            setOperand(operand: 0.0)
        }
    }
    
    // MARK: Program section
    private var internalProgram = [Any]()
    typealias PropertyList = Any    // AnyObject doesn't work
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [Any] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }

    // MARK: Description section
    private var currentPrecedence = Int.max
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }

    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }

    var isPartialResult: Bool {
        return pending != nil
    }
    
//    private func getNumberForDescription(_ number: Double) -> String {
//        if let strNumber=formatter.string(from: NSNumber(value: number)) {
//            return strNumber
//        }
//        return "0"
//    }
}

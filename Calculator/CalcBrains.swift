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

//class CalcBrains {
struct CalcBrains {
    // MARK: Operation section
    //private var accumulator = 0.0
    private var accumulator: Double?
    
    let formatter = DefaultNumberFormatter()

    mutating func setOperand (_ operand : Double) {
        accumulator = operand
        // desc acc can be a symbol of a constant
        if descriptionAccumulator == " ", let accumulatorValue = accumulator {
            descriptionAccumulator = formatter.string(from: NSNumber(value: accumulatorValue)) ?? ""
        }
        internalProgram.append(operand)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" :   .constant(Double.pi),    // M_PI
        "e" :   .constant(M_E),
        "√" :   .unaryOp(sqrt, { "√(" + $0 + ")" }),
        "cos" : .unaryOp(cos, { "cos(" + $0 + ")" }),
        "sin" : .unaryOp(sin, { "sin(" + $0 + ")" }),
        "tan" : .unaryOp(tan, { "tan(" + $0 + ")" }),
        "ln" :  .unaryOp(log, { "ln(" + $0 + ")" }),
        "+/-" : .unaryOp({ -$0 },{ "-(" + $0 + ")" }),
        "x⁻¹" : .unaryOp({ 1.0/$0 }, { "1/(" + $0 + ")" }),
        "x²" :  .unaryOp({ $0*$0 }, { "(" + $0 + ")²" }),
        "eˣ" :  .unaryOp({ pow(M_E, $0) }, { "e^" + $0 }),
        //"×" : .binaryOp(multiply),
        //"×" : .binaryOp({ $0 * $1 }),
        //"÷" : .binaryOp({ $0 / $1 }),
        //"+" : .binaryOp({ $0 + $1 }),
        //"−" : .binaryOp({ $0 - $1 }),
        "×" :   .binaryOp(*, { $0 + " × " + $1 }, 1),
        "÷" :   .binaryOp(/, { $0 + " ÷ " + $1 }, 1),
        "+" :   .binaryOp(+, { $0 + " + " + $1 }, 0),
        "−" :   .binaryOp(-, { $0 + " - " + $1 }, 0),
        "xʸ":   .binaryOp(pow, { $0 + " ^ " + $1 }, 2),
        "=" :   .equals,
        "Rand": .random({ Double(arc4random()) / Double(UINT32_MAX) }),
        // not used
        "asin" : .unaryOp(asin, { "asin(" + $0 + ")"}),
        "acos" : .unaryOp(acos, { "acos(" + $0 + ")"}),
        "atan" : .unaryOp(atan, { "atan(" + $0 + ")"})
    ]
        
    private enum Operation {
        case constant(Double)
        case unaryOp((Double) -> Double, (String) -> String)
        case binaryOp((Double,Double) -> Double, (String,String) -> String, Int)
        case equals
        case random(() -> Double)
    }
    
    mutating func performOperation (_ symbol: String) {
        internalProgram.append(symbol)
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value) :
                //if !isPartialResult { clear() }     // clear state when new expression starts
                accumulator = value
                descriptionAccumulator = symbol
            case .unaryOp(let function, let descriptionFunction) :
                if let operand = accumulator {
                    accumulator = function(operand)
                }
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .binaryOp(let function, let descriptionFunction, let precedence) :
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                if accumulator != nil {
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator!,
                                                   descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                }
                // desc acc should contain last operand only
                descriptionAccumulator = " "
            case .equals :
                executePendingBinaryOperation()
            case .random(let random) :
                accumulator = random()
                descriptionAccumulator = "rand()"
            }
        }
    }
    
    private mutating func executePendingBinaryOperation() {
        if pending != nil {
            if accumulator != nil {
                accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator!)
            }
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
    
    mutating func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        descriptionAccumulator = " "
        currentPrecedence = Int.max
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    // MARK: Variables section
    var variableNames: Dictionary<String, Double> = [:]
    
    mutating func setOperandWithVariable(_ variableName: String) {
        if let variableValue = variableNames[variableName] {
            setOperand(variableValue)
        } else {
            setOperand(0.0)
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
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
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

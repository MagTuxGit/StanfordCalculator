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
        "√" :   .unaryOperation(sqrt, { "√(" + $0 + ")" }),
        "cos" : .unaryOperation(cos, { "cos(" + $0 + ")" }),
        "sin" : .unaryOperation(sin, { "sin(" + $0 + ")" }),
        "tan" : .unaryOperation(tan, { "tan(" + $0 + ")" }),
        "ln" :  .unaryOperation(log, { "ln(" + $0 + ")" }),
        "+/-" : .unaryOperation({ -$0 },{ "-(" + $0 + ")" }),
        "x⁻¹" : .unaryOperation({ 1.0/$0 }, { "1/(" + $0 + ")" }),
        "x²" :  .unaryOperation({ $0*$0 }, { "(" + $0 + ")²" }),
        "eˣ" :  .unaryOperation({ pow(M_E, $0) }, { "e^" + $0 }),
        //"×" : .binaryOp(multiply),
        //"×" : .binaryOp({ $0 * $1 }),
        //"÷" : .binaryOp({ $0 / $1 }),
        //"+" : .binaryOp({ $0 + $1 }),
        //"−" : .binaryOp({ $0 - $1 }),
        "×" :   .binaryOperation(*, { $0 + " × " + $1 }, 1),
        "÷" :   .binaryOperation(/, { $0 + " ÷ " + $1 }, 1),
        "+" :   .binaryOperation(+, { $0 + " + " + $1 }, 0),
        "−" :   .binaryOperation(-, { $0 + " - " + $1 }, 0),
        "xʸ":   .binaryOperation(pow, { $0 + " ^ " + $1 }, 2),
        "=" :   .equals,
        "Rand": .random({ Double(arc4random()) / Double(UINT32_MAX) }),
        // not used
        "asin" : .unaryOperation(asin, { "asin(" + $0 + ")"}),
        "acos" : .unaryOperation(acos, { "acos(" + $0 + ")"}),
        "atan" : .unaryOperation(atan, { "atan(" + $0 + ")"})
    ]
        
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double,Double) -> Double, (String,String) -> String, Int)
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
            case .unaryOperation(let function, let descriptionFunction) :
                if let operand = accumulator {
                    accumulator = function(operand)
                    descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                }
            case .binaryOperation(let function, let descriptionFunction, let precedence) :
                executePendingBinaryOperation()

                if accumulator != nil {
                    if currentPrecedence < precedence {
                        descriptionAccumulator = "(" + descriptionAccumulator + ")"
                    }
                    currentPrecedence = precedence
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!,
                                                   descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                    accumulator = nil
                    descriptionAccumulator = " "
                }
            case .equals :
                executePendingBinaryOperation()
            case .random(let random) :
                accumulator = random()
                descriptionAccumulator = "rand()"
            }
        }
    }
    
    private mutating func executePendingBinaryOperation() {
        if pendingBinaryOperation != nil, accumulator != nil {
            //accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator!)
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            
            //descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator)
            
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double

        let descriptionFunction: (String, String) -> String
        let descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }

        func performDescription(with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
        }
    }
    
    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
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
    private var descriptionAccumulator = " " {
        didSet {
            if pendingBinaryOperation == nil {
                currentPrecedence = Int.max
            }
        }
    }

    var description: String {
        get {
            if pendingBinaryOperation == nil {
                return descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand,
                                                    pendingBinaryOperation!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }

    var isPartialResult: Bool {
        return pendingBinaryOperation != nil
    }
    
//    private func getNumberForDescription(_ number: Double) -> String {
//        if let strNumber=formatter.string(from: NSNumber(value: number)) {
//            return strNumber
//        }
//        return "0"
//    }
}

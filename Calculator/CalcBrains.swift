//
//  CalcBrains.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 12/13/16.
//  Copyright © 2016 Andrij Trubchanin. All rights reserved.
//
// description implementation was taken here https://github.com/m2mtech/calculator-2016

import Foundation

func factorial(_ op1: Double) -> Double {
    if (op1 <= 1) {
        return 1
    }
    return op1 * factorial(op1 - 1.0)
}

struct CalcBrains {

    // MARK: Program
    private enum programItem {
        case operand(Double)
        case variable(String)
        case operation(String)
    }
    
    private var program = [programItem]()

    // MARK: Public interface
    mutating func setOperand (_ operand : Double) {
        program.append(.operand(operand))
    }
    
    mutating func setOperand(variableName: String) {
        program.append(.variable("M"))
    }

    mutating func performOperation (_ symbol: String) {
        program.append(.operation(symbol))
    }
    
    mutating func clear() {
        program.removeAll()
    }

    // MARK: Deprecated public interface
    var result: Double? {
        return evaluate().result
    }
    
    var description: String {
        return evaluate().description
    }
    
    var resultIsPending: Bool {
        return evaluate().isPending
    }

    // MARK: Operations
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
        "2ˣ" :  .unaryOperation({ pow(2, $0) }, { "2^" + $0 }),
        "eˣ" :  .unaryOperation({ pow(M_E, $0) }, { "e^" + $0 }),
        "x!" :  .unaryOperation(factorial, { "(" + $0 + ")!" }),
        //"×" : .binaryOp(multiply),
        //"×" : .binaryOp({ $0 * $1 }),
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
    
    // MARK: EVALUATE
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        let formatter = DefaultNumberFormatter()
        var accumulator: Double?

        var pendingBinaryOperation: PendingBinaryOperation?
        var isPending: Bool {
            return pendingBinaryOperation != nil
        }

        var currentPrecedence = Int.max
        var descriptionAccumulator = " " {
            didSet {
                if pendingBinaryOperation == nil {
                    currentPrecedence = Int.max
                }
            }
        }
        
        var description: String {
            if pendingBinaryOperation == nil {
                return descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand,
                                                                   pendingBinaryOperation!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }

        func clear() {
            accumulator = nil
            pendingBinaryOperation = nil
            descriptionAccumulator = " "
            currentPrecedence = Int.max
        }

        func setOperand (_ operand : Double) {
            accumulator = operand
            // desc acc can be a symbol of a constant
            if descriptionAccumulator == " ", let accumulatorValue = accumulator {
                descriptionAccumulator = formatter.string(from: NSNumber(value: accumulatorValue)) ?? ""
            }
        }
        
        func setOperand (variableName: String) {
            descriptionAccumulator = variableName
            if let variableValue = variables?[variableName] {
                setOperand(variableValue)
            } else {
                setOperand(0.0)
            }
        }
        
        struct PendingBinaryOperation {
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

        func performOperation (_ symbol: String) {
            if let operation = operations[symbol] {
                switch operation {
                case .constant(let value) :
                    if !isPending { clear() }     // clear state when new expression starts
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
        
        func executePendingBinaryOperation() {
            if pendingBinaryOperation != nil, accumulator != nil {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator)
                pendingBinaryOperation = nil
            }
        }
        
        for op in program {
            switch op {
            case .operand(let value) :
                setOperand(value)
            case .operation(let operation):
                performOperation(operation)
            case .variable(let variableName):
                setOperand(variableName: variableName)
            }
        }
        
        return (result: accumulator, isPending: isPending, description: description)
    }
}

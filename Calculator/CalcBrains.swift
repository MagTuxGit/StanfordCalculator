//
//  CalcBrains.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 12/13/16.
//  Copyright © 2016 Andrij Trubchanin. All rights reserved.
//

import Foundation

func multiply(op1: Double, op2: Double) -> Double {
    return op1 * op2
}

class CalcBrains {
    private var accumulator = 0.0
    private var internalProgram = [Any]()
    
    func setOperand (operand : Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOp(sqrt),
        "cos" : Operation.UnaryOp(cos),
        "±" : Operation.UnaryOp({ -$0 }),
        //"×" : Operation.BinaryOp(multiply),
        "×" : Operation.BinaryOp({ $0 * $1 }),
        "÷" : Operation.BinaryOp({ $0 / $1 }),
        "+" : Operation.BinaryOp({ $0 + $1 }),
        "−" : Operation.BinaryOp({ $0 - $1 }),
        "=" : Operation.Equals
    ]
        
    private enum Operation {
        case Constant(Double)
        case UnaryOp((Double) -> Double)
        case BinaryOp((Double,Double) -> Double)
        case Equals
    }
    
    func performOperation (symbol: String) {
        /*
        switch symbol {
        case "π" : accumulator = M_PI
        case "√" : accumulator = sqrt(accumulator)
        default : break
        }
        */
        internalProgram.append(symbol)
        
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value) :
                accumulator = value
            case .UnaryOp(let function) :
                accumulator = function(accumulator)
            case .BinaryOp(let function) :
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals :
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            self.accumulator = self.pending!.binaryFunction(self.pending!.firstOperand, self.accumulator)
            self.pending = nil
        }
    }

    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
    }
    
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

    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
}

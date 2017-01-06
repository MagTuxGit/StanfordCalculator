//
//  CalcBrains.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 12/13/16.
//  Copyright © 2016 Andrij Trubchanin. All rights reserved.
//

import Foundation

/*
func multiply(op1: Double, op2: Double) -> Double {
    return op1 * op2
}

func removeLastChar(value: Double) -> Double {
    var valStr = String(value)
    valStr.remove(at: valStr.index(before: valStr.endIndex))
    return Double(valStr)!
}
*/

class CalcBrains {
    private var accumulator = 0.0
    private var internalProgram = [Any]()
    
    var description = ""    // fixed part
    var lastOperand = ""    // last operand for unary operators wrapping
    var isPartialResult: Bool {
        return pending != nil
    }
    
    func setOperand (operand : Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOp(sqrt),
        "cos" : Operation.UnaryOp(cos),
        "sin" : Operation.UnaryOp(sin),
        "tan" : Operation.UnaryOp(tan),
        "ln" : Operation.UnaryOp(log),
        "+/-" : Operation.UnaryOp({ -$0 }),
        "1/x" : Operation.UnaryOp({ 1/$0 }),
        //"←" : Operation.UnaryOp(removeLastChar),
        //"×" : Operation.BinaryOp(multiply),
        "×" : Operation.BinaryOp({ $0 * $1 }),
        "÷" : Operation.BinaryOp({ $0 / $1 }),
        "+" : Operation.BinaryOp({ $0 + $1 }),
        "−" : Operation.BinaryOp({ $0 - $1 }),
        "=" : Operation.Equals,
        "rand": Operation.Random({ Double(arc4random()) / Double(UINT32_MAX) })
    ]
        
    private enum Operation {
        case Constant(Double)
        case UnaryOp((Double) -> Double)
        case BinaryOp((Double,Double) -> Double)
        case Equals
        case Random(() -> Double)
    }
    
    func getNumberForDescription(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        formatter.minimumIntegerDigits = 1
        if let strNumber=formatter.string(from: NSNumber(value: number)) {
            return strNumber
        }
        return "0"
    }
    
    func addBinaryToDescription(_ symbol: String) {
        // "1+"  - lastOp is empty, descr is empty, use acc "1" as lastOp
        // "1++" - descr = "1+", lastOp is empty, isPart true, use acc "1" as lastOp (result is 1+1+)
        if lastOperand.isEmpty && (isPartialResult || description.isEmpty) { lastOperand = getNumberForDescription(accumulator) }
        // fix lastop and symbol
        description += lastOperand + symbol
        lastOperand = ""
    }
    
    func addUnaryToDescription(_ symbol: String) {
        // prepare symbols for output
        var symbolEdited = symbol
        switch symbol {
        case "+/-": symbolEdited = "-"
        case "1/x": symbolEdited = "1/"
        default: break
        }
        
        if isPartialResult {
            // "1+2√" - descr = "1+", lastop is empty, use acc "2" as lastop
            if lastOperand.isEmpty { lastOperand = getNumberForDescription(accumulator) }
            // wrap lastop into operation and save to lastop
            lastOperand = symbolEdited + "(" + lastOperand + ")"
        } else {
            // "2√" - lastop is empty, descr is empty, use acc "2" as lastop
            // "1+2=√" - lastop is empty, use descr "1+2" as lastop, result is "√(1+2)"
            // here lastop is always empty
            if lastOperand.isEmpty { lastOperand = (description.isEmpty ? getNumberForDescription(accumulator) : description) }
            // wrap lastop into operation and fix result
            description = symbolEdited + "(" + lastOperand + ")"
            lastOperand = ""
        }
    }
    
    func addEqualsToDescription() {
        // fix lastop
        description += lastOperand
        lastOperand = ""
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
                if !isPartialResult { clear() }     // clear state when new expression starts
                lastOperand = symbol               // use symbol as lastop
                accumulator = value
            case .UnaryOp(let function) :
                addUnaryToDescription(symbol)
                accumulator = function(accumulator)
            case .BinaryOp(let function) :
                executePendingBinaryOperation()
                addBinaryToDescription(symbol)
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals :
                executePendingBinaryOperation()
                addEqualsToDescription()
            case .Random(let random) :
                accumulator = random()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            // "1+2=", lastop is empty, descr = "1+", use acc "2" as lastop
            if lastOperand.isEmpty { lastOperand = getNumberForDescription(accumulator) }
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
        description = ""
        lastOperand = ""
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
}

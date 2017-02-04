//
//  CalCenter.swift
//  MyCalculator
//
//  Created by jingshun chen on 1/31/17.
//  Copyright © 2017 jingshun chen. All rights reserved.
//

import Foundation
class CalCenter
{
    enum Operation{
        case UnaryOperation((Double)->Double)
        case BinaryOperation((Double, Double)->Double)
        case Parentheses
    }
    
    enum Operator: String {
        case Add = "+"
        case Minus = "-"
        case Mutiply = "*"
        case Divide = "/"
        case Negate = "-/+"
        case Point = "."
        case LeftParentheses = "("
        case RightParentheses = ")"
    }
    
    struct OperationInfo{
        var theOperand : Double?
        var theOperator : Operator?
        //var isCalculated : Bool = false
        
        init(_ operand:Double?, inputOperator op: Operator?) {
            theOperand = operand
            theOperator = op
        }
    }
 
    private var operationDic: Dictionary<Operator, Operation> = [
        Operator.Add : Operation.BinaryOperation({$0 + $1}),
        Operator.Minus : Operation.BinaryOperation({$0 - $1}),
        Operator.Mutiply : Operation.BinaryOperation({$0 * $1}),
        Operator.Divide : Operation.BinaryOperation({$0 / $1}),
        Operator.Point : Operation.BinaryOperation({$0 + $1 / pow(10, floor(log10($1)) + 1)}),
        
        Operator.Negate : Operation.UnaryOperation({0 - $0}),
        
        Operator.LeftParentheses: Operation.Parentheses,
        Operator.RightParentheses:Operation.Parentheses
    ]
    
    private var _leftParenthesesCount = 0;
    
    private var _accumulator:Double?
    var accumulator: Double? {
        return _accumulator
    }
    
    private var _backup: Array <OperationInfo> = []
    private var _tempHistory: Array <OperationInfo> = []
    private var _history: Array <OperationInfo> = []
    var history : Array <OperationInfo> {
        return _history
    }
    
    func undo(){
        if (_history.count > 0){
            _backup.append(_history.remove(at: _history.count-1))
        }
    }
    
    func redo(){
        if (_backup.count > 0){
            _history.append(_backup.remove(at: _backup.count-1))
        }
    }
    
    func reset(){
        _accumulator = nil
        _history.removeAll()
    }
    
    func setOperand(operand:Double){
        if(_history.isEmpty || _history.last!.theOperator != Operator.RightParentheses){
            if (_accumulator == nil){
                _accumulator = 0
            }
            _accumulator = _accumulator! * 10 + operand
        }
    }
  
    func getFuncFromOperator(_ op:Operator?) ->((Double, Double) -> Double?)?{
        var rtnVal:((Double, Double) ->Double)? = nil
        if op != nil {
            if let oprn = self.operationDic[op!]{
                switch oprn {
                case .BinaryOperation(let foo) :
                    rtnVal = foo
                default:
                    break
                }
            }
        }
        return rtnVal
    }
    
    func calculateGroup(_ arr:Array<Operator>, beginIndex begin:Int,endIndex end:Int){
        for i in begin..<end {
            if (!_tempHistory[i].isCalculated)
                && (_tempHistory[i].theOperator != nil)
                && (arr.contains(_tempHistory[i].theOperator!)) {
                for  j in i+1..<end {
                    if !_tempHistory[j].isCalculated && _tempHistory[j].theOperand != nil{
                        _tempHistory[j].theOperand = getFuncFromOperator(_tempHistory[i].theOperator)!(
                            _tempHistory[i].theOperand!,
                            _tempHistory[j].theOperand!)
                        _tempHistory[i].isCalculated = true
                    }
                }
            }
        }
    }
    
    func getReselut() -> Double?{
        var rtn :Double? = nil
        if isOperandAtLast() && self._leftParenthesesCount == 0{
            self._tempHistory = self._history
            if (_accumulator != nil){
                let info = OperationInfo(_accumulator, inputOperator: nil)
                _tempHistory.append(info )
            }
            calculateGroup([Operator.Point], beginIndex: 0, endIndex: _tempHistory.count)
            for j in 0..<_tempHistory.count {
                if _tempHistory[j ].theOperator == Operator.RightParentheses {
                    for i in (0..<j).reversed() {
                        if (_tempHistory[i].theOperator == Operator.LeftParentheses){
                            calculateGroup([Operator.Mutiply,Operator.Divide], beginIndex: i+1, endIndex: j+1)
                            calculateGroup([Operator.Add,Operator.Minus], beginIndex: i+1, endIndex: j+1)
                            _tempHistory[i].isCalculated = true
                            if (j+1 < _tempHistory.count){
                                _tempHistory[j+1].theOperand = _tempHistory[j].theOperand
                                _tempHistory[j].isCalculated = true
                            }
                        }
                    }
                }
            }
            calculateGroup([Operator.Mutiply,Operator.Divide], beginIndex: 0, endIndex: _tempHistory.count)
            calculateGroup([Operator.Add,Operator.Minus], beginIndex: 0, endIndex: _tempHistory.count)
            rtn = _tempHistory.last!.theOperand
        }
        return rtn
    }
    
    func isOperandAtLast() -> Bool {
        if _accumulator != nil {
            return true
        }
        if _history.last?.theOperator == Operator.RightParentheses {
            return true
        }
        return false
    }
    
    func performOperation(oprtor:Operator){
        if let oprtn = self.operationDic[oprtor] {
            switch oprtn{
            case .BinaryOperation( _) :
                if oprtor == Operator.Point
                    && (_history.last?.theOperator == Operator.Point
                        || _history.last?.theOperator == Operator.RightParentheses){
                    break
                }
                if !isOperandAtLast() {
                    break
                }
                let info = OperationInfo(accumulator!, inputOperator : oprtor )
                _history.append (info)
                _accumulator = nil
                
            case .UnaryOperation(let foo) :
                if !isOperandAtLast(){
                    _accumulator = foo(_accumulator!)
                }
            
            case .Parentheses:
                if oprtor == Operator.LeftParentheses {
                    if isOperandAtLast(){
                        break
                    }
                    _leftParenthesesCount += 1
                } else {
                    if _leftParenthesesCount == 0 {
                        break
                    }
                    _leftParenthesesCount -= 1
                }
                let info = OperationInfo(accumulator, inputOperator: oprtor )
                _history.append(info )
                _accumulator = nil
            }
        }
    }
    
}

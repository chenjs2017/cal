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
    
    private var _oldAccumulator: Double?
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
    
    private var _currentOperation:Int?
    private var _eraseCurrentValue = false
    
    func prewOperand(){
        if _currentOperation == nil {
            _currentOperation = _history.count
        }
        for i in (0..<_currentOperation!).reversed() {
            if _history[i].theOperand != nil {
                _currentOperation = i
                _eraseCurrentValue = true
                break
            }
        }
    }
    func nextOperand(){
        if _currentOperation == nil {
            return
        }
        for i in _currentOperation!+1..<_history.count{
            if _history[i].theOperand != nil {
                _currentOperation = i
                _eraseCurrentValue = true
                return
            }
        }
        _currentOperation = nil
    }
    func undo(){
        if (_accumulator != nil) {
            _oldAccumulator = _accumulator
            _accumulator = nil
        } else if (_history.count > 0){
            _backup.append(_history.remove(at: _history.count-1))
            
        }
    }
    
    func redo(){
        if (_backup.count > 0){
            _history.append(_backup.remove(at: _backup.count-1))
        } else if _oldAccumulator != nil {
            _accumulator = _oldAccumulator
            _oldAccumulator = nil
        }
    }
    
    func reset(){
        _accumulator = nil
        _history.removeAll()
    }
    
    func setOperand(operand:Double){
        if (_currentOperation == nil ){
            if(_history.isEmpty || _history.last!.theOperator != Operator.RightParentheses){
                if (_accumulator == nil){
                    _accumulator = 0
                }
                _accumulator = _accumulator! * 10 + operand
            }
        } else {
            if (_eraseCurrentValue){
                _eraseCurrentValue = false
                _history[_currentOperation!].theOperand = 0
            }
            _history[_currentOperation!].theOperand = _history[_currentOperation!].theOperand! * 10 + operand
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
        var i = begin
        var varEnd = end
      
        while (i < varEnd) {
            if (_tempHistory[i].theOperator != nil)
                && arr.contains(_tempHistory[i].theOperator!) {
                if _tempHistory[i + 1].theOperand != nil{
                    _tempHistory[i + 1].theOperand =
                        getFuncFromOperator(_tempHistory[i].theOperator)!(
                            _tempHistory[i].theOperand!,
                            _tempHistory[i+1].theOperand!)
                    _tempHistory.remove(at: i)
                                        i = i - 1
                    varEnd = varEnd - 1
                }
            }
            i = i + 1
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
            var j = 0
            while j < _tempHistory.count {
                if _tempHistory[j].theOperator == Operator.RightParentheses {
                    var i = j - 1
                    while (i >= 0) {
                        if (_tempHistory[i].theOperator == Operator.LeftParentheses){
                            let oldCount = _tempHistory.count
                            calculateGroup([Operator.Mutiply,Operator.Divide], beginIndex: i+1, endIndex: j+1)
                            calculateGroup([Operator.Add,Operator.Minus], beginIndex: i+1, endIndex: j+1)
                            _tempHistory.remove(at: i)
                            j = j - (oldCount - _tempHistory.count)
                            if (j + 1 < _tempHistory.count){
                                _tempHistory[j+1].theOperand = _tempHistory[j].theOperand
                               _tempHistory.remove(at: j)
                            }
                            j = j - 1
                            break
                        }
                        i = i - 1
                    }
                }
                j = j + 1
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
                let info = OperationInfo(accumulator, inputOperator : oprtor )
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

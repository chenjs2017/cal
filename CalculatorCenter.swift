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
        case Exponent = "^"
        case Sqrt = "√"
        case Qbrt = "∛"
        case Divid100 = "%"
    }
    
    struct OperationInfo{
        var theOperand : Double?
        var theOperator : Operator?
    }
 
    private var operationDic: Dictionary<Operator, Operation> = [
        Operator.Add : Operation.BinaryOperation({$0 + $1}),
        Operator.Minus : Operation.BinaryOperation({$0 - $1}),
        Operator.Mutiply : Operation.BinaryOperation({$0 * $1}),
        Operator.Divide : Operation.BinaryOperation({$0 / $1}),
        Operator.Point : Operation.BinaryOperation({$0 + $1 / pow(10, floor(log10($1)) + 1)}),
        Operator.Exponent : Operation.BinaryOperation({pow($0, $1)}),
        Operator.Negate : Operation.UnaryOperation({0 - $0}),
        Operator.Sqrt : Operation.UnaryOperation({sqrt($0)}),
        Operator.Qbrt : Operation.UnaryOperation({pow($0, (1.0/3.0))}),
        Operator.Divid100 : Operation.UnaryOperation({$0 / 100}),
        Operator.LeftParentheses: Operation.Parentheses,
        Operator.RightParentheses:Operation.Parentheses
    ]
    
    private var _leftParenthesesCount = 0;
    
    private var _backup: Array <OperationInfo> = []
    private var _tempHistory: Array <OperationInfo> = []
    private var _history: Array <OperationInfo> = []
    var history : Array <OperationInfo> {
        return _history
    }
    
    private var _reverseIndex = 0
    var currentIndex:Int{
        return _history.count - 1 - _reverseIndex
    }
    private var _eraseCurrentValue = false
    
    func prewOperand(){
        let current = _history.count - 1 - _reverseIndex
        for i in (0..<current).reversed() {
            if _history[i].theOperand != nil {
                _reverseIndex = _history.count - 1 - i
                _eraseCurrentValue = true
                break
            }
        }
    }
    func nextOperand(){
        let current = _history.count - 1 - _reverseIndex
        for i in current + 1..<_history.count{
            if _history[i].theOperand != nil {
                _reverseIndex = _history.count - 1 - i
                _eraseCurrentValue = true
                return
            }
        }
    }
    
    func undo(){
        if !_history.isEmpty {
            _backup.append(_history.removeLast())
        }
    }
    
    func redo(){
        if !_backup.isEmpty {
            _history.append(_backup.removeLast())
        }
    }
    
    func reset(){
        _history.removeAll()
        _reverseIndex = 0
    }
    
    func setOperand(operand:Double){
        if(_history.isEmpty || (_history.last!.theOperator != nil) && (_history.last!.theOperator != Operator.RightParentheses)){
            let info = OperationInfo(theOperand: operand, theOperator: nil)
            _history.append(info)
            _eraseCurrentValue = false
            
        } else {
            let current = _history.count - 1 - _reverseIndex
            if (_eraseCurrentValue){
                _eraseCurrentValue = false
                _history[current].theOperand = 0
            }
            _history[current].theOperand = _history[current].theOperand! * 10 + operand
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
        if (_history.last?.theOperator == nil || _history.last?.theOperator == Operator.RightParentheses)
            && self._leftParenthesesCount == 0 && _history.count > 1{
            self._tempHistory = self._history
            calculateGroup([Operator.Point], beginIndex: 0, endIndex: _tempHistory.count)
            var j = 0
            while j < _tempHistory.count {
                if _tempHistory[j].theOperator == Operator.RightParentheses {
                    var i = j - 1
                    while (i >= 0) {
                        if (_tempHistory[i].theOperator == Operator.LeftParentheses){
                            var oldCount = _tempHistory.count
                            calculateGroup([Operator.Exponent], beginIndex: 0, endIndex: _tempHistory.count)
                            j = j - (oldCount - _tempHistory.count)

                            oldCount = _tempHistory.count
                            calculateGroup([Operator.Mutiply,Operator.Divide], beginIndex: i+1, endIndex: j+1)
                            j = j - (oldCount - _tempHistory.count)
                            
                            oldCount = _tempHistory.count
                            calculateGroup([Operator.Add,Operator.Minus], beginIndex: i+1, endIndex: j+1)
                            j = j - (oldCount - _tempHistory.count)
                            
                            
                            if (j + 1 < _tempHistory.count){
                                _tempHistory[j+1].theOperand = _tempHistory[j].theOperand
                               _tempHistory.remove(at: j)
                            }
                            j = j - 1
                            
                            _tempHistory.remove(at: i)
                            break
                        }
                        i = i - 1
                    }
                }
                j = j + 1
            }
            calculateGroup([Operator.Exponent], beginIndex: 0, endIndex: _tempHistory.count)
            calculateGroup([Operator.Mutiply,Operator.Divide], beginIndex: 0, endIndex: _tempHistory.count)
            calculateGroup([Operator.Add,Operator.Minus], beginIndex: 0, endIndex: _tempHistory.count)
            rtn = _tempHistory.last!.theOperand
        }
        return rtn
    }
    
    func performOperation(oprtor:Operator){
        if let oprtn = self.operationDic[oprtor] {
            switch oprtn{
            case .BinaryOperation( _) :
                if _history.isEmpty{
                    break
                }
                if oprtor == Operator.Point
                    && (_history.last!.theOperator == Operator.Point
                        || _history.last!.theOperator == Operator.RightParentheses){
                    break
                }
                if _history.last!.theOperator == nil {
                    _history[_history.count-1].theOperator = oprtor
                } else if _history.last!.theOperator == Operator.RightParentheses {
                    _history.append(OperationInfo(theOperand: nil, theOperator: oprtor))
                }
            case .UnaryOperation(let foo) :
                if _history.isEmpty{
                    break;
                }
                let current = _history.count - 1 - _reverseIndex
                _history[current].theOperand = foo(_history[current].theOperand!)
                
            case .Parentheses:
                if oprtor == Operator.LeftParentheses {
                    if (_history.isEmpty
                        || _history.last!.theOperator == Operator.LeftParentheses
                        || (_history.last!.theOperator != nil && _history.last!.theOperator != Operator.Point) ) {
                        _leftParenthesesCount += 1
                        _history.append(OperationInfo(theOperand: nil, theOperator: oprtor))
                    }
                } else {
                    if _leftParenthesesCount > 0 {
                        _leftParenthesesCount -= 1
                        _history[_history.count-1].theOperator = oprtor
                    }
                }
                
            }
        }
    }
    
}

//
//  CalCenter.swift
//  MyCalculator
//
//  Created by jingshun chen on 1/31/17.
//  Copyright © 2017 jingshun chen. All rights reserved.
//

import Foundation
import CoreData

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
    
    struct OprationInfo{
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
    
    private var _backupOperationList: Array <OprationInfo> = []
    private var _tempOperationList: Array <OprationInfo> = []
    private var _currentOperationList: Array <OprationInfo> = []
    
        
    var currentOperationList : Array <OprationInfo> {
        return _currentOperationList
    }
    
    private var _reverseIndex = 0
    private var currentIndex:Int{
        return _currentOperationList.count - 1 - _reverseIndex
    }
    private var _eraseCurrentValue = false
    
    func prewOperand(){
        let current = _currentOperationList.count - 1 - _reverseIndex
        for i in (0..<current).reversed() {
            if _currentOperationList[i].theOperand != nil {
                _reverseIndex = _currentOperationList.count - 1 - i
                _eraseCurrentValue = true
                break
            }
        }
    }
    func nextOperand(){
        let current = _currentOperationList.count - 1 - _reverseIndex
        for i in current + 1..<_currentOperationList.count{
            if _currentOperationList[i].theOperand != nil {
                _reverseIndex = _currentOperationList.count - 1 - i
                _eraseCurrentValue = true
                return
            }
        }
    }
    
    func undo(){
        if !_currentOperationList.isEmpty {
            _backupOperationList.append(_currentOperationList.removeLast())
        }
    }
    
    func redo(){
        if !_backupOperationList.isEmpty {
            _currentOperationList.append(_backupOperationList.removeLast())
        }
    }
    
    func reset(){
        _currentOperationList.removeAll()
        _reverseIndex = 0
       
    }
    
    func initByHistory(_ arr: Array<OprationInfo>){
        _currentOperationList = arr
        _reverseIndex = 0
        //calculate left parenthesis
        for info in arr {
            if info.theOperator == Operator.LeftParentheses {
                self._leftParenthesesCount += 1
            } else if (info.theOperator == Operator.RightParentheses) {
                self._leftParenthesesCount -= 1
            }
        }
    }
    
    func setOperand(operand:Double){
        if(_currentOperationList.isEmpty
            || (_currentOperationList.last!.theOperator != nil)
            && (_currentOperationList.last!.theOperator != Operator.RightParentheses)){
            let info = OprationInfo(theOperand: operand, theOperator: nil)
            _currentOperationList.append(info)
            _eraseCurrentValue = false
            
        } else {
            let current = _currentOperationList.count - 1 - _reverseIndex
            if (_eraseCurrentValue){
                _eraseCurrentValue = false
                _currentOperationList[current].theOperand = 0
            }
            _currentOperationList[current].theOperand = _currentOperationList[current].theOperand! * 10 + operand
        }
    }
  
    private func getFuncFromOperator(_ op:Operator?) ->((Double, Double) -> Double?)?{
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
    
    private func calculateGroup(_ arr:Array<Operator>, beginIndex begin:Int,endIndex end:Int){
        var i = begin
        var varEnd = end
        while (i < varEnd) {
            if (_tempOperationList[i].theOperator != nil)
                && arr.contains(_tempOperationList[i].theOperator!) {
                if _tempOperationList[i + 1].theOperand != nil
                    && _tempOperationList[i].theOperand != nil {
                    _tempOperationList[i + 1].theOperand =
                        getFuncFromOperator(_tempOperationList[i].theOperator)!(
                            _tempOperationList[i].theOperand!,
                            _tempOperationList[i+1].theOperand!)
                    _tempOperationList.remove(at: i)
                    i -= 1
                    varEnd -= 1
                }
            }
            i += 1
        }
    }
    
    private func calculateGroupAndGetChange(_ arr:Array<Operator>, beginIndex begin:Int,endIndex end:Int) -> Int {
        let count = _tempOperationList.count
        calculateGroup( arr, beginIndex: begin, endIndex: end )
        return count - _tempOperationList.count
    }
    
    func getReselut() -> Double?{
        var rtn :Double? = nil
        if (_currentOperationList.last?.theOperator == nil
            || _currentOperationList.last?.theOperator == Operator.RightParentheses)
            && self._leftParenthesesCount == 0 && _currentOperationList.count > 1{
            
            self._tempOperationList = _currentOperationList
            calculateGroup([Operator.Point], beginIndex: 0, endIndex: _tempOperationList.count)
            var j = 0
            while j < _tempOperationList.count {
                if _tempOperationList[j].theOperator == Operator.RightParentheses {
                    var i = j - 1
                    while (i >= 0) {
                        if (_tempOperationList[i].theOperator == Operator.LeftParentheses){
                            j -= calculateGroupAndGetChange([Operator.Exponent], beginIndex: i+1, endIndex: j+1)
                            j -= calculateGroupAndGetChange([Operator.Mutiply,Operator.Divide], beginIndex: i+1, endIndex: j+1)
                            j -= calculateGroupAndGetChange([Operator.Add,Operator.Minus], beginIndex: i+1, endIndex: j+1)

                            
                            if (j + 1 < _tempOperationList.count){
                                _tempOperationList[j+1].theOperand = _tempOperationList[j].theOperand
                                _tempOperationList.remove(at: j)
                                j -= 1
                            }
                                                        
                            _tempOperationList.remove(at: i)
                            j -= 1
                            break
                        }
                        i -= 1
                    }
                }
                j += 1
            }
            calculateGroup([Operator.Exponent], beginIndex: 0, endIndex: _tempOperationList.count)
            calculateGroup([Operator.Mutiply,Operator.Divide], beginIndex: 0, endIndex: _tempOperationList.count)
            calculateGroup([Operator.Add,Operator.Minus], beginIndex: 0, endIndex: _tempOperationList.count)
            rtn = _tempOperationList.last!.theOperand
        }
        return rtn
    }
    
    func performOperation(oprtor:Operator){
        if let oprtn = self.operationDic[oprtor] {
            switch oprtn{
            case .BinaryOperation( _) :
                if _currentOperationList.isEmpty{
                    break
                }
                if oprtor == Operator.Point {                   
                    if _currentOperationList.count > 1 {
                        let pre = _currentOperationList[_currentOperationList.count - 2]
                        if pre.theOperator == Operator.Point
                            || _currentOperationList.last!.theOperator == Operator.RightParentheses{
                             break
                        }
                    }
                }
                if _currentOperationList.last!.theOperator == Operator.RightParentheses {
                    _currentOperationList.append(OprationInfo(theOperand: nil, theOperator: oprtor))
                } else if _currentOperationList.last!.theOperator == nil {
                    _currentOperationList[_currentOperationList.count-1].theOperator = oprtor
                }
            case .UnaryOperation(let foo) :
                if _currentOperationList.isEmpty{
                    break;
                }
                let current = _currentOperationList.count - 1 - _reverseIndex
                _currentOperationList[current].theOperand = foo(_currentOperationList[current].theOperand!)
                
            case .Parentheses:
                if oprtor == Operator.LeftParentheses {
                    if (_currentOperationList.isEmpty
                        || _currentOperationList.last!.theOperator == Operator.LeftParentheses
                        || (_currentOperationList.last!.theOperator != nil
                            && _currentOperationList.last!.theOperator != Operator.Point) ) {
                        _leftParenthesesCount += 1
                        _currentOperationList.append(OprationInfo(theOperand: nil, theOperator: oprtor))
                    }
                } else {
                    if _leftParenthesesCount > 0 {
                        _leftParenthesesCount -= 1
                        let index = _currentOperationList.count-1
                        if _currentOperationList[index].theOperator != Operator.RightParentheses{
                            _currentOperationList[index].theOperator = oprtor
                        } else {
                            _currentOperationList.append(OprationInfo(theOperand: nil, theOperator: oprtor))
                        }
                    }
                }
                
            }
        }
    }
    
    private func getDoubleString(_ doubleVal:Double) -> String{
        var  rtn = String (doubleVal)
        if (rtn.hasSuffix(".0")) {
            let index = rtn.index(rtn.endIndex, offsetBy: -2)
            rtn = rtn.substring(to: index )
        }
        return rtn
    }
    
    func toString() -> (String, NSRange?) {
        var txt = ""
        var i = 0
        var begin = -1
        var length = 0
        for info in _currentOperationList {
            if let tmp = info.theOperand {
                let t = getDoubleString(tmp)
                if (i == self.currentIndex) {
                    begin = txt.characters.count
                    length = t.characters.count
                }
                txt += t
            }
            if let tmp = info.theOperator {
                txt += tmp.rawValue
            }
            
            i = i + 1
        }
        
        if let tmp = getReselut(){
            txt += "="
            txt += getDoubleString(tmp)
        }
        var range : NSRange? = nil
        if (begin > -1) {
            range = NSRange(location: begin,length: length)
        }
        return (txt, range )
    }
    
}

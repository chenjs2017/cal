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
        var isCalculated : Bool = false
        
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
    
    private var _tempHistory: Array <OperationInfo> = []
    private var _history: Array <OperationInfo> = []
    var history : Array <OperationInfo> {
        return _history
    }
    
    func reset(){
        _accumulator = nil
        _history.removeAll()
    }
    
    func setOperand(operand:Double){
        if (_accumulator == nil)
        {
            _accumulator = 0
        }
        _accumulator = _accumulator! * 10 + operand       
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
    func calculatePoint(beginIndex begin:Int,endIndex end:Int)
    {
        //calculate '.' first
        for i in begin..<end {
            var info = _tempHistory[i]
            if (!info.isCalculated) && (info.theOperator == Operator.Point) {
                var next = _tempHistory[i + 1]
                let foo = getFuncFromOperator(info.theOperator)
                info.isCalculated = true
                next.theOperand = foo!(info.theOperand!, next.theOperand!)
            }
        }
    }
    func getReselut() -> Double?{
        if _accumulator == nil{
            return nil
        }
        self._tempHistory = self._history
        
        // 1 ".",
        self.calculatePoint(beginIndex: 0, endIndex: self._tempHistory.count)
        //2 "()" 
        //3, */, 4 +-
        //var currentVal :Double? = nil
        //var lastFunc :((Double, Double) -> Double?)? = nil
    
        //for info in _history {
          //  if (currentVal == nil) {
            //    currentVal = info.theOperand
            //} else {
//            //    currentVal = lastFunc! (currentVal!, info.theOperand)
            //}
            //if let tmp = info.theOperator {
              //  lastFunc = getFuncFromOperator(tmp)
            //}
        //}
        //if lastFunc != nil {
          //  currentVal = lastFunc!(currentVal!, self._accumulator!)
        //}
        return 0
    }
    
    func performOperation(oprtor:Operator){
        if let oprtn = self.operationDic[oprtor] {
            switch oprtn{
            case .BinaryOperation( _) :
                //can't have 2 '.' in a row
                if oprtor == Operator.Point && _history.last?.theOperator == Operator.Point{
                    break
                }
                
                if _accumulator == nil {
                    break
                }
                let info = OperationInfo(accumulator!, inputOperator : oprtor )
                _history.append (info)
                _accumulator = nil
                
            case .UnaryOperation(let foo) :
                if _accumulator != nil {
                    _accumulator = foo(_accumulator!)
                }
            
            case .Parentheses:
                if oprtor == Operator.LeftParentheses {
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

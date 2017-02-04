//
//  ViewController.swift
//  MyCalculator
//
//  Created by jingshun chen on 1/29/17.
//  Copyright © 2017 jingshun chen. All rights reserved.
//

import UIKit

class CalculatorVC: UIViewController {
    
   
    @IBOutlet weak var displayTextView: UITextView!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var rightParentheses: UIButton!
    @IBOutlet weak var leftParentheses: UIButton!
    @IBOutlet weak var negateButton: UIButton!
    @IBOutlet weak var pointButton: UIButton!
    
    private let _center = CalCenter()
    
    //map button to Operator
    private var _buttonOperatorDict = Dictionary<UIButton, CalCenter.Operator>()
    private var buttonOperatorDict :Dictionary<UIButton, CalCenter.Operator>{
        if _buttonOperatorDict.isEmpty{
            _buttonOperatorDict[multiplyButton] = CalCenter.Operator.Mutiply
            _buttonOperatorDict[minusButton] = CalCenter.Operator.Minus
            _buttonOperatorDict[addButton] = CalCenter.Operator.Add
            _buttonOperatorDict[divideButton] = CalCenter.Operator.Divide
            _buttonOperatorDict[negateButton] = CalCenter.Operator.Negate
            _buttonOperatorDict[pointButton] = CalCenter.Operator.Point
            _buttonOperatorDict[leftParentheses] = CalCenter.Operator.LeftParentheses
            _buttonOperatorDict[rightParentheses] = CalCenter.Operator.RightParentheses
        }
        return _buttonOperatorDict
    }
    
    private func getDoubleString(_ doubleVal:Double) -> String{
        var rtn : String = ""
        let intVal = Int(doubleVal)
        if (intVal < 0){
            rtn += "("
        }
        
        if doubleVal - Double (intVal) == 0 {
            rtn += String (intVal)
        } else {
            rtn += String (doubleVal)
        }
        
        if (intVal < 0){
            rtn += ")"
        }
        return rtn
    }

    private func updateUI(){
        var txt = ""
        for info in _center.history {
            if let tmp = info.theOperand {
                txt += getDoubleString(tmp)
            }
            if let tmp = info.theOperator {
                txt += tmp.rawValue
            }
        }
        
        if let tmp = _center.accumulator {
            txt += getDoubleString(tmp )
        }
        
        if let tmp = _center.getReselut(){
            txt += "="
            txt += getDoubleString(tmp)
        }
        displayTextView.text = txt
    }
    
    @IBAction func touchOperator(_ sender: UIButton) {
        if let tmp = buttonOperatorDict[sender] {
            _center.performOperation(oprtor: tmp)
            updateUI()
        }
    }
    @IBAction private func touchDigit(_ sender: UIButton) {
        _center.setOperand(operand: Double(sender.tag))
        updateUI()
    }
    
    @IBAction func allClear(_ sender: Any) {
        _center.reset()
        updateUI()
    }
    
    override func viewDidLoad() {
        //let a = pow(10, floor(log10(150.0)) + 1)
        //let b = a;
        //let s = String(describing: b)
        //displayTextView.text = s
    }
}


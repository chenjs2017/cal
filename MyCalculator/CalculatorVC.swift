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
    @IBOutlet weak var pointButton: UIButton!
    @IBOutlet weak var pwrButton: UIButton!
    @IBOutlet weak var negateButton: UIButton!
    @IBOutlet weak var sqrtButton: UIButton!
    @IBOutlet weak var qbrtButton: UIButton!
    @IBOutlet weak var divide100: UIButton!
    
    
    private let _center = CalCenter()
    
    //map button to Operator
    private var _buttonOperatorDict = Dictionary<UIButton, CalCenter.Operator>()
    private var buttonOperatorDict :Dictionary<UIButton, CalCenter.Operator>{
        if _buttonOperatorDict.isEmpty{
            _buttonOperatorDict[multiplyButton] = CalCenter.Operator.Mutiply
            _buttonOperatorDict[minusButton] = CalCenter.Operator.Minus
            _buttonOperatorDict[addButton] = CalCenter.Operator.Add
            _buttonOperatorDict[divideButton] = CalCenter.Operator.Divide
            _buttonOperatorDict[pointButton] = CalCenter.Operator.Point
            _buttonOperatorDict[leftParentheses] = CalCenter.Operator.LeftParentheses
            _buttonOperatorDict[rightParentheses] = CalCenter.Operator.RightParentheses
            _buttonOperatorDict[pwrButton] = CalCenter.Operator.Exponent
            _buttonOperatorDict[negateButton] = CalCenter.Operator.Negate
            _buttonOperatorDict[sqrtButton] = CalCenter.Operator.Sqrt
            _buttonOperatorDict[qbrtButton] = CalCenter.Operator.Qbrt
            _buttonOperatorDict[divide100] = CalCenter.Operator.Divid100
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
        var i = 0
        var begin = -1
        var length = 0
        for info in _center.history {
            if let tmp = info.theOperand {
                let t = getDoubleString(tmp)
                if (i == _center.currentIndex) {
                    begin = txt.characters.count
                    length = t.characters.count                }
                txt += t
                
                
            }
            if let tmp = info.theOperator {
                txt += tmp.rawValue
            }
            
            i = i + 1
        }
        
        if let tmp = _center.getReselut(){
            txt += "="
            txt += getDoubleString(tmp)
        }
        let attrString = NSMutableAttributedString(string: txt,
                                                   attributes: [ NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
        if (begin > -1) {
            attrString.setAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 24)], range: NSRange(location: begin,length: length))
        }
        displayTextView.attributedText = attrString
    }
    
    @IBAction func touchRedo(_ sender: UIButton) {
        _center.redo()
        updateUI()
    }
    @IBAction func touchUndo(_ sender: Any) {
        _center.undo()
        updateUI()
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
    
    @IBAction func touchPrew(_ sender: Any) {
        _center.prewOperand()
        updateUI()
    }
    @IBAction func touchNext(_ sender: Any) {
        _center.nextOperand()
        updateUI()
    }
    
    @IBAction func touchAllClear(_ sender: Any) {
        _center.reset()
        updateUI()
    }
    
    @IBAction func openTouched(_ sender: Any) {
    }
    override func viewDidLoad() {
    
    }
}


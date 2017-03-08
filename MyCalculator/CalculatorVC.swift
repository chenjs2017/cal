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
    private weak var _managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    private var _currentFormula: FormulaInfo? = nil
   

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
    
   

    private func updateUI(_ autoSave:Bool){
        let result = _center.toString()
        
        let attrString = NSMutableAttributedString(string: result.0,
                                                   attributes: [ NSFontAttributeName: UIFont.systemFont(ofSize: 18)])
        if (result.1 != nil) {
            attrString.setAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 20)], range: (result.1)! )
        }
        
        displayTextView.attributedText = attrString
        if (autoSave) {
            _currentFormula?.saveOperationInfos(_center.currentOperationList)
        }
    }
    
    @IBAction func touchRedo(_ sender: UIButton) {
        _center.redo()
        updateUI(true)
    }
    @IBAction func touchUndo(_ sender: Any) {
        _center.undo()
        updateUI(true)
    }
    @IBAction func touchOperator(_ sender: UIButton) {
        if let tmp = buttonOperatorDict[sender] {
            _center.performOperation(oprtor: tmp)
            updateUI(true)
        }
    }
    @IBAction private func touchDigit(_ sender: UIButton) {
        _center.setOperand(operand: Double(sender.tag))
        updateUI(true)
    }
    
    @IBAction func touchPrew(_ sender: Any) {
        _center.prewOperand()
        updateUI(false)
    }
    @IBAction func touchNext(_ sender: Any) {
        _center.nextOperand()
        updateUI(false)
    }
    
    @IBAction func touchAllClear(_ sender: Any) {
        _currentFormula = FormulaInfo.newFormula(managedContext: _managedContext!)
        _center.reset()
        updateUI(false)
    }
    
    @IBAction func openTouched(_ sender: Any) {
    }
    override func viewDidLoad() {
        resetUI(FormulaInfo.getLatestOrNew(managedContext: _managedContext!))
    }
    
    func resetUI(_ formular: FormulaInfo?){
        if formular == nil {
            return
        }
        
        _currentFormula = formular
        _center.initByHistory((_currentFormula?.getCalOperationInfo())!)
        updateUI(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showList"){
            
            let na = segue.destination as! UINavigationController
            let tbc = na.childViewControllers[0] as! FormulaTVC
            tbc.setCalVC(self)
        }
    }
}


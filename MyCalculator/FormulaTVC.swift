//
//  LogTVC.swift
//  MyCalculator
//
//  Created by jingshun chen on 2/28/17.
//  Copyright © 2017 jingshun chen. All rights reserved.
//

import UIKit

class FormulaTVC: UITableViewController {
    private var _formulas : [FormulaInfo]? = nil
    private weak var  _managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    private var _cal :CalculatorVC? = nil
    
    func setCalVC(_ cal: CalculatorVC){
        _cal = cal
    }
    
    
    func close(_ info:FormulaInfo?){
        _cal?.resetUI(info)
        self.dismiss(animated: false, completion: {
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _formulas = FormulaInfo.getAll(managedContext: _managedContext!)!
        
    }
    @IBAction func touchNewBtn(_ sender: UIBarButtonItem) {
        self.close(FormulaInfo.newFormula(managedContext: _managedContext!))
    }
    
    @IBAction func touchBackBtn(_ sender: UIBarButtonItem) {
        self.close(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _formulas!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "formula", for: indexPath)
        let formula = _formulas?[indexPath.row]
        let formulaCell = cell as? FormulaTVCell
        formulaCell?.initWithFormularInfo(formula!,parent: self )
        return cell
    }
    
    
    
}

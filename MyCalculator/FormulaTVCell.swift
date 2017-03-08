//
//  LogCell.swift
//  MyCalculator
//
//  Created by jingshun chen on 3/1/17.
//  Copyright © 2017 jingshun chen. All rights reserved.
//

import UIKit

class FormulaTVCell: UITableViewCell {

    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var formularButton: UIButton!
    @IBOutlet weak var nameButton: UIButton!
    private weak var _formulaInfo : FormulaInfo? = nil
    private weak var _tvc: FormulaTVC? = nil
    
    @IBAction func touchFormulaButton(_ sender: Any) {
        _formulaInfo?.updateFormulaIndex()
        _tvc?.close(_formulaInfo)
    }
   
    @IBAction func touchFavoriteButton(_ sender: Any) {
        changeFavorite()
    }

    func changeFavorite() {
        _formulaInfo?.isFavorite = !(_formulaInfo?.isFavorite)!
        _formulaInfo?.save()
        updateUI()
    }
    
    @IBAction func touchFormulaName(_ sender: Any) {
        getFormulaNamefromPopup()
      
    }
    func getFormulaNamefromPopup (){
        let alert = UIAlertController(title: "Formula Name", message: "Enter a name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = self._formulaInfo!.formulaName
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            self._formulaInfo?.formulaName = textField.text
            self._formulaInfo?.save()
            self.updateUI()
        }))
        _tvc?.present(alert,animated: false, completion: nil)
    }
    
    func initWithFormularInfo(_ info:FormulaInfo, parent vc:FormulaTVC  ) {
        _formulaInfo = info
        _tvc = vc
        updateUI()
    }
    
    func updateUI() {
        nameButton.setTitle(_formulaInfo?.formulaName, for: .normal)
        formularButton.setTitle (_formulaInfo?.getString(), for:.normal)
        favoriteBtn.setTitle((_formulaInfo?.isFavorite)! ?" ★ ":" ✩ ", for :.normal )
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

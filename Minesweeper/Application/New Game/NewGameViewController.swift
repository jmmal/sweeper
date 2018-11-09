//
//  NewGameViewController.swift
//  Minesweeper
//
//  Created by Josh Maloney on 6/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var rowCountLabel: UILabel!
    @IBOutlet weak var columnCountLabel: UILabel!
    @IBOutlet weak var mineCountLabel: UILabel!
    
    @IBOutlet weak var rowCountSlider: UISlider!
    @IBOutlet weak var columnCountSlider: UISlider!
    @IBOutlet weak var mineCountSlider: UISlider!
    
    // MARK: - Properties
    var numRows: Int = 9
    var numColumns: Int = 9
    var numMines: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rowCountSlider.value = Float(numRows)
        columnCountSlider.value = Float(numColumns)
        mineCountSlider.value = Float(numMines)
        
        updateLabels()
    }
    
    func updateLabels() {
        rowCountLabel.text = String(numRows)
        columnCountLabel.text = String(numColumns)
        mineCountLabel.text = String(numMines)
    }
    
    @IBAction func rowSliderMoved(_ sender: UISlider) {
        numRows = Int(sender.value.rounded())
        updateLabels()
    }
    
    @IBAction func columnSliderMoved(_ sender: UISlider) {
        numColumns = Int(sender.value.rounded())
        updateLabels()
    }
    
    @IBAction func mineSliderMoved(_ sender: UISlider) {
        numMines = Int(sender.value.rounded())
        updateLabels()
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if (segue.identifier == "beginGameSegue") {
            let vc = segue.destination as! GridCollectionViewController
            vc.numRows = numRows
            vc.numColumns = numColumns
            vc.numMines = numMines
        } else if segue.identifier == "easyGameSegue" {
            let vc = segue.destination as! GridCollectionViewController
            vc.numRows = 8
            vc.numColumns = 8
            vc.numMines = 10
        } else if segue.identifier == "mediumGameSegue" {
            let vc = segue.destination as! GridCollectionViewController
            vc.numRows = 16
            vc.numColumns = 16
            vc.numMines = 40
        } else if segue.identifier == "expertGameSegue" {
            let vc = segue.destination as! GridCollectionViewController
            vc.numRows = 24
            vc.numColumns = 24
            vc.numMines = 99
        }
    }
}

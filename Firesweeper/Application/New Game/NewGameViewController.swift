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
    var numRows: Int = 8
    var numColumns: Int = 8
    var numMines: Int = 10

    // MARK: - Lifecycle Hooks
    override func viewDidLoad() {
        super.viewDidLoad()

        updateView()
    }

    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isHidden = true
        updateView()
    }

    // MARK: - View Updates
    private func updateView() {
        rowCountSlider.value = Float(numRows)
        columnCountSlider.value = Float(numColumns)
        mineCountSlider.value = Float(numMines)

        updateLabels()
    }

    private func updateLabels() {
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
        if let gridVC = segue.destination as? GameCollectionViewController {
            if segue.identifier == "easyGameSegue" {
                numRows = 8
                numColumns = 8
                numMines = 10
            } else if segue.identifier == "mediumGameSegue" {
                numRows = 16
                numColumns = 16
                numMines = 40
            } else if segue.identifier == "expertGameSegue" {
                numRows = 24
                numColumns = 24
                numMines = 99
            }

            gridVC.game = Game(rows: numRows, columns: numColumns, mines: numMines)
        }
    }
}

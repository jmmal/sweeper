//
//  GridCollectionViewCell.swift
//  Minesweeper
//
//  Created by Josh Maloney on 6/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gridCellLabel: UILabel!
    
    func displayHidden() {
        self.backgroundColor = .lightGray
        self.gridCellLabel.text = ""
    }
    
    func displayNumber(surroundingMines: Int) {
        self.backgroundColor = .white
        
        if surroundingMines == 0 {
            self.gridCellLabel.text = ""
        } else {
            self.gridCellLabel.text = "\(surroundingMines)"
        }
    }
    
    func displayMarked() {
        self.backgroundColor = .lightGray
        self.gridCellLabel.text = "🍆"
    }
    
    func displayMine() {
        self.backgroundColor = .black
        self.gridCellLabel.text = "🔥"
    }
}

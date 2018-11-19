//
//  GridCollectionViewCell.swift
//  Minesweeper
//
//  Created by Josh Maloney on 6/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
// swiftlint:disable multiple_closures_with_trailing_closure

import UIKit

class GameCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gridCellLabel: UILabel!

    func displayHidden(shouldAnimate animate: Bool) {
        self.backgroundColor = .lightGray
        self.gridCellLabel.text = ""

        if animate {
            animateCell()
        }
    }

    func displayNumber(surroundingMines: Int) {
        self.backgroundColor = .white

        if surroundingMines == 0 {
            self.gridCellLabel.text = ""
        } else {
            self.gridCellLabel.text = "\(surroundingMines)"
        }
    }

    func displayMarked(shouldAnimate animate: Bool) {
        self.backgroundColor = .lightGray
        self.gridCellLabel.text = "🍆"

        if animate {
            animateCell()
        }
    }

    func displayMine() {
        self.backgroundColor = .black
        self.gridCellLabel.text = "🔥"
    }

    func animateCell() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 4, y: 4)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
}

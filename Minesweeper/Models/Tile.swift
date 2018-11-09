//
//  Tile.swift
//  Minesweeper
//
//  Created by Josh Maloney on 7/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import Foundation

class Tile {
    var isShown: Bool
    var isMarked: Bool
    var isMine: Bool
    var surroundingMinesCount: Int

    init(isMine: Bool, surroundingMinesCount: Int) {
        self.isShown = false
        self.isMarked = false
        self.isMine = isMine
        self.surroundingMinesCount = surroundingMinesCount
    }
}

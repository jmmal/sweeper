//
//  Tile.swift
//  Minesweeper
//
//  Created by Josh Maloney on 7/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import Foundation

enum TileDisplayState {
    case hidden
    case marked
    case number
    case mine
}

class Tile {
    // MARK: - Tile Characteristics
    var isShown: Bool
    var isMarked: Bool
    var isMine: Bool
    var shouldAnimate: Bool = false

    var surroundingMinesCount: Int
    var rowNum: Int
    var colNum: Int

    // MARK: - Initialiser
    init(isMine: Bool, surroundingMinesCount: Int, row: Int, col: Int) {
        self.isShown = false
        self.isMarked = false
        self.isMine = isMine
        self.surroundingMinesCount = surroundingMinesCount
        self.rowNum = row
        self.colNum = col
    }

    // MARK: - Other
    // Returns the current state the tile should be displayed as
    func currentDisplayState() -> TileDisplayState {
        if isMarked {
            return .marked
        }

        if !isShown {
            return .hidden
        }

        if isMine {
            return .mine
        }

        return .number
    }
}

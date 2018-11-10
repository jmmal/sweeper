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

    func displayState() -> TileDisplayState {
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

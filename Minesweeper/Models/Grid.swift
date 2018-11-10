//
//  Game.swift
//  Minesweeper
//
//  Created by Josh Maloney on 10/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import Foundation

enum GridState {
    case won
    case lost
    case inProgress
    case notStarted
}

class Grid {
    let numRows: Int
    let numCols: Int
    let numMines: Int

    var minesRemaining: Int = 0

    var grid = [[Tile]]()

    var state: GridState?

    init(rows: Int, columns: Int, mines: Int) {
        numRows = rows
        numCols = columns
        numMines = mines
    }

    // Randomises the placement of mines on the board and setuo tile counts
    func newGame() {
        state = .notStarted
        minesRemaining = numMines

        buildGrid()
        placeMines()
        countMines()
    }

    // Initialises the board size
    private func buildGrid() {
        grid = [[Tile]]()
        for rowIndex in 0..<numRows {
            var row = [Tile]()

            for colIndex in 0..<numCols {
                row.append(Tile(isMine: false, surroundingMinesCount: 0, row: rowIndex, col: colIndex))
            }

            grid.append(row)
        }
    }

    private func placeMines() {
        var minesLeftToPlace = numMines

        while minesLeftToPlace > 0 {
            let randRow = Int.random(in: 0..<numRows)
            let randCol = Int.random(in: 0..<numCols)

            // Check cell not already a mine
            if !isMineAt(randRow, randCol) {
                setMineAt(randRow, randCol)
                minesLeftToPlace -= 1
            }
        }
    }

    private func countMines() {
        for row in 0..<numRows {
            for col in 0..<numCols {
                var count: Int = 0

                let adjacentTiles = getAdjacentTiles(row, col)

                for tile in adjacentTiles where tile.isMine {
                    count += 1
                }

                grid[row][col].surroundingMinesCount = count
            }
        }
    }

    // Stops the game. Sets all mines to be displayed
    func showAllMines() {
        for row in 0..<numRows {
            for col in 0..<numCols where grid[row][col].isMine {
                grid[row][col].isShown = true
            }
        }
    }

    func gameWon() -> Bool {
        if state == .notStarted {
            return false
        }

        for row in 0..<numRows {
            for col in 0..<numCols {
                if isMineAt(row, col) && !isMarkedAt(row, col) {
                    return false
                }

                if !isMineAt(row, col) && !isShownAt(row, col) {
                    return false
                }
            }
        }

        return true
    }

    func getState() -> GridState? {
        return state
    }

    func selectTileAt(_ indexPath: IndexPath) {
        if state == .notStarted {
            state = .inProgress
        }

        let tile = tileAt(indexPath: indexPath)

        if tile.isShown || tile.isMarked {
            return
        }

        if tile.surroundingMinesCount == 0 && !tile.isMine {
            selectSurroundingCells(indexPath.row, indexPath.section)
        }

        setShownAt(indexPath.row, indexPath.section)
    }

    func markTileAt(_ indexPath: IndexPath) {
        let tile = tileAt(indexPath: indexPath)

        if !tile.isShown {
            if tile.isMarked {
                minesRemaining += 1
                tile.isMarked = false
            } else if minesRemaining > 0 {
                minesRemaining -= 1
                tile.isMarked = true
            }
        }
    }

    //
    func tileAt(_ row: Int, _ col: Int) -> Tile {
        return grid[row][col]
    }

    func tileAt(indexPath: IndexPath) -> Tile {
        return grid[indexPath.row][indexPath.section]
    }

    //
    func mineCountAt(_ row: Int, _ col: Int) -> Int {
        return grid[row][col].surroundingMinesCount
    }

    func isMineAt(_ row: Int, _ col: Int) -> Bool {
        return grid[row][col].isMine
    }

    func isMarkedAt(_ row: Int, _ col: Int) -> Bool {
        return grid[row][col].isMarked
    }

    func isShownAt(_ row: Int, _ col: Int) -> Bool {
        return grid[row][col].isShown
    }

    func setShownAt(_ row: Int, _ col: Int) {
        grid[row][col].isShown = true

        if grid[row][col].isMine {
            state = .lost
            showAllMines()
        }
    }

    func setMarkedAt(_ row: Int, _ col: Int) {
        grid[row][col].isMarked = true
    }

    func unmarkAt(_ row: Int, _ col: Int) {
        grid[row][col].isMarked = false
    }

    private func setMineAt(_ row: Int, _ col: Int) {
        grid[row][col].isMine = true
    }

    private func getAdjacentTiles(_ row: Int, _ col: Int) -> [Tile] {
        var adjacents = [Tile]()

        // Check Top
        if row > 0 {
            // TopLeft
            if col > 0 {
                adjacents.append(tileAt(row - 1, col - 1))
            }

            // TopTop
            adjacents.append(tileAt(row - 1, col))

            // TopRight
            if col + 1 < numCols {
                adjacents.append(tileAt(row - 1, col + 1))
            }
        }

        // Check Left
        if col > 0 {
            adjacents.append(tileAt(row, col - 1))
        }

        // Check Right
        if col + 1 < numCols {
            adjacents.append(tileAt(row, col + 1))
        }

        // Check Down
        if row + 1 < numRows {
            // Bottom Left
            if col > 0 {
                adjacents.append(tileAt(row + 1, col - 1))
            }

            // Bottom Bottom
            adjacents.append(tileAt(row + 1, col))

            // Bottom Right
            if col + 1 < numCols {
                adjacents.append(tileAt(row + 1, col + 1))
            }
        }

        return adjacents
    }

    func selectSurroundingCells(_ row: Int, _ col: Int) {
        if tileAt(row, col).isShown {
            return
        }

        tileAt(row, col).isShown = true

        if mineCountAt(row, col) != 0 {
            return
        }

        let adjacentTiles = getAdjacentTiles(row, col)

        for tile in adjacentTiles {
            selectSurroundingCells(tile.rowNum, tile.colNum)
        }
    }
}

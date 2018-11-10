//
//  Game.swift
//  Minesweeper
//
//  Created by Josh Maloney on 10/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import Foundation

protocol GameControllerDelegate: class {
    func gameSecondsCountDidUpdate(game: Game, withTotalSeconds: Int)
    func gameStateDidUpdate(game: Game, withState state: GridState)
}

class Game {
    weak var delegate: GameControllerDelegate?

    var timer: Timer?
    let grid: Grid

    let numRows: Int
    let numColumns: Int
    let numMines: Int

    var secondsCount: Int = 0

    init(rows: Int, columns: Int, mines: Int) {
        numRows = rows
        numColumns = columns
        numMines = mines
        grid = Grid(rows: numRows, columns: numColumns, mines: numMines)
    }

    func setup() {
        grid.newGame()

        secondsCount = 0
        self.delegate?.gameSecondsCountDidUpdate(game: self, withTotalSeconds: self.secondsCount)
        self.delegate?.gameStateDidUpdate(game: self, withState: .notStarted)
    }

    func stopGame() {
        stopTimer()
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.secondsCount += 1
            self.delegate?.gameSecondsCountDidUpdate(game: self, withTotalSeconds: self.secondsCount)
        })
    }

    func reset() {
        stopTimer()
        setup()
    }

    func selectTileAt(_ indexPath: IndexPath) {
        if grid.getState() == .lost {
            return
        }

        if grid.getState() == .notStarted {
            startTimer()
            self.delegate?.gameStateDidUpdate(game: self, withState: .inProgress)
        }

        grid.selectTileAt(indexPath)
        checkGameState()
    }

    func markTileAt(_ indexPath: IndexPath) {
        if grid.getState() == .lost {
            return
        }

        grid.markTileAt(indexPath)
        checkGameState()
    }

    func checkGameState() {
        if grid.getState() == .lost {
            stopGame()
            self.delegate?.gameStateDidUpdate(game: self, withState: .lost)
            return
        }

        if grid.gameWon() == true {
            stopGame()
            self.delegate?.gameStateDidUpdate(game: self, withState: .won)
        }
    }

    func getRemainingMines() -> Int {
        return grid.minesRemaining
    }

    func getTileForCellAt(indexPath: IndexPath) -> Tile {
        return grid.tileAt(indexPath: indexPath)
    }
}

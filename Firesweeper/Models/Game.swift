//
//  Game.swift
//  Minesweeper
//
//  Created by Josh Maloney on 10/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.

import Foundation
import CoreData
import UIKit

@objc enum GameStatType: Int16 {
    case won
    case lost
    case quit
}

@objc enum GameType: Int16 {
    case easy
    case medium
    case hard
    case custom
}

protocol GameControllerDelegate: class {
    func gameSecondsCountDidUpdate(game: Game, withTotalSeconds: Int)
    func gameStateDidUpdate(game: Game, withState state: GridState)
}

class Game {
    // MARK: - Properties
    weak var delegate: GameControllerDelegate?

    private var timer: Timer?
    private let grid: Grid

    let numRows: Int
    let numColumns: Int
    let numMines: Int
    var secondsCount: Int = 0
    var statsToReport: Bool = false

    // MARK: - Initialisers
    init(rows: Int, columns: Int, mines: Int) {
        numRows = rows
        numColumns = columns
        numMines = mines
        grid = Grid(rows: numRows, columns: numColumns, mines: numMines)
    }

    private func reportStatistics(withState state: GameStatType = GameStatType.quit) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext

        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "GameStatistic",
                                       in: managedContext)!

        let stat = NSManagedObject(entity: entity,
                                     insertInto: managedContext)

        var gameType = GameType.RawValue()
        if numRows == 8 && numColumns == 8 && numMines == 10 {
            gameType = GameType.easy.rawValue
        } else if numRows == 16 && numColumns == 16 && numMines == 40 {
            gameType = GameType.medium.rawValue
        } else if numRows == 24 && numColumns == 24 && numMines == 99 {
            gameType = GameType.hard.rawValue
        } else {
            gameType = GameType.custom.rawValue
        }

        stat.setValue(numRows, forKey: "rowSize")
        stat.setValue(numColumns, forKey: "colSize")
        stat.setValue(secondsCount, forKey: "totalTime")
        stat.setValue(state.rawValue, forKey: "gameStatus")
        stat.setValue(gameType, forKey: "gameType")

        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        statsToReport = false
    }

    func setup() {
        if statsToReport {
            reportStatistics()
            statsToReport = false
        }

        grid.newGame()

        secondsCount = 0
        self.delegate?.gameSecondsCountDidUpdate(game: self, withTotalSeconds: self.secondsCount)
        self.delegate?.gameStateDidUpdate(game: self, withState: .notStarted)
    }

    func reset() {
        stopTimer()
        setup()
    }

    private func stopGame() {
        stopTimer()
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.secondsCount += 1
            self.delegate?.gameSecondsCountDidUpdate(game: self, withTotalSeconds: self.secondsCount)
        })
    }

    // MARK: - Grid Actions
    func selectTileAt(_ indexPath: IndexPath) {
        if grid.getState() == .lost {
            return
        }

        if grid.getState() == .notStarted {
            statsToReport = true
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

    func getRemainingMines() -> Int {
        return grid.minesRemaining
    }

    func getTileForCellAt(indexPath: IndexPath) -> Tile {
        return grid.tileAt(indexPath: indexPath)
    }

    // MARK: - GameState
    func checkGameState() {
        if grid.getState() == .lost {
            stopGame()
            reportStatistics(withState: GameStatType.lost)
            self.delegate?.gameStateDidUpdate(game: self, withState: .lost)
            return
        }

        if grid.gameWon() == true {
            print("won")
            stopGame()
            reportStatistics(withState: GameStatType.won)
            self.delegate?.gameStateDidUpdate(game: self, withState: .won)
        }
    }
}

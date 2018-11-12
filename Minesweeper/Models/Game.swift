//
//  Game.swift
//  Minesweeper
//
//  Created by Josh Maloney on 10/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
// swiftlint:disable force_try

import Foundation
import CoreData
import UIKit

@objc enum GameStatType: Int16 {
    case won = 1
    case lost = 2
    case quit = 3
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

    private func reportStatistics() {
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

        let state = grid.getState()
        var gameType = GameStatType.RawValue()

        if state == .won {
            gameType = GameStatType.won.rawValue
        } else if state == .lost {
            gameType = GameStatType.lost.rawValue
        } else {
            gameType = GameStatType.quit.rawValue
        }

        stat.setValue(numRows, forKey: "rowSize")
        stat.setValue(numColumns, forKey: "colSize")
        stat.setValue(secondsCount, forKey: "totalTime")
        stat.setValue(gameType, forKey: "gameStatus")

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
            reportStatistics()
            self.delegate?.gameStateDidUpdate(game: self, withState: .lost)
            return
        }

        if grid.gameWon() == true {
            stopGame()
            reportStatistics()
            self.delegate?.gameStateDidUpdate(game: self, withState: .won)
        }
    }
}

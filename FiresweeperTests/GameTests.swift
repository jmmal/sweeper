//
//  GameTests.swift
//  MinesweeperTests
//
//  Created by Josh Maloney on 12/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import XCTest

@testable import Firesweeper

class GameTests: XCTestCase, GameControllerDelegate {
    func gameSecondsCountDidUpdate(game: Game, withTotalSeconds: Int) {
        testExpectationSeconds.fulfill()
    }

    func gameStateDidUpdate(game: Game, withState state: GridState) {
        gameState = state
    }

    private var testGame: Game!
    private weak var testExpectationSeconds: XCTestExpectation!
    private var gameState: GridState!

    private let testRows: Int = 3
    private let testCols: Int = 3
    private let testMines: Int = 3

    override func setUp() {
        testGame = Game(rows: testRows, columns: testCols, mines: testMines)
        testGame.delegate = self
        testExpectationSeconds = expectation(description: "Seconds")
    }

    override func tearDown() {
        testGame = nil
        gameState = nil
        testExpectationSeconds = nil
    }

    func testSetsUpGameProperly() {
        // When
        testGame.setup()

        // Then
        wait(for: [testExpectationSeconds], timeout: 100)
        XCTAssert(testGame.secondsCount == 0)
    }

    func testReturnsCorrectGameWonState() {
        // Given
        testGame.setup()

        // When
        for rowIndex in 0..<testRows {
            for colIndex in 0..<testCols {
                let tile = testGame.getTileForCellAt(indexPath: IndexPath(row: rowIndex, section: colIndex))

                if tile.isMine {
                    testGame.markTileAt(IndexPath(row: rowIndex, section: colIndex))
                } else {
                    testGame.selectTileAt(IndexPath(row: rowIndex, section: colIndex))
                }
            }
        }

        testGame.checkGameState()

        // Then
        wait(for: [testExpectationSeconds], timeout: 100)
        XCTAssert(gameState == .won)
    }

    func testReturnsCorrectGameLostState() {
        // Given
        testGame.setup()

        // When
        for rowIndex in 0..<testRows {
            for colIndex in 0..<testCols {
                let tile = testGame.getTileForCellAt(indexPath: IndexPath(row: rowIndex, section: colIndex))

                if tile.isMine {
                    testGame.selectTileAt(IndexPath(row: rowIndex, section: colIndex))
                }
            }
        }

        testGame.checkGameState()

        // Then
        wait(for: [testExpectationSeconds], timeout: 100)
        XCTAssert(gameState == .lost)
    }
}

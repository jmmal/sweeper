//
//  GridTests.swift
//  MinesweeperTests
//
//  Created by Josh Maloney on 12/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import XCTest

@testable import Minesweeper

class GridTests: XCTestCase {
    var testGrid: Grid!
    let testGridRows: Int = 3
    let testGridCols: Int = 3
    let testGridMines: Int = 3

    override func setUp() {
        testGrid = Grid(rows: testGridRows, columns: testGridCols, mines: testGridMines)
    }

    override func tearDown() {
        testGrid = nil
    }

    func testCorrectlyInitialisesGrid() {
        // Then
        XCTAssertEqual(testGrid.numRows, testGridRows, "Incorrect number of rows")
        XCTAssertEqual(testGrid.numCols, testGridCols, "Incorrect number of cols")
        XCTAssertEqual(testGrid.numMines, testGridMines, "Incorrect number of mines")
    }

    func testGridPlacesTheRightNumberOfMines() {
        // Given
        testGrid.newGame()

        // When
        testGrid.newGame()

        // Then
        var mineCount = 0

        for rowIndex in 0..<testGridRows {
            for colIndex in 0..<testGridCols {
                let tile = testGrid.tileAt(rowIndex, colIndex)

                if tile.isMine {
                    mineCount += 1
                }
            }
        }

        XCTAssertEqual(mineCount, testGridMines, "Incorrect number of mines set")
    }

    func testCorrectlyRecognisesGameWonState() {
        // Given
        testGrid.newGame()

        // When
        for rowIndex in 0..<testGridRows {
            for colIndex in 0..<testGridCols {
                let tile = testGrid.tileAt(rowIndex, colIndex)

                if tile.isMine {
                    testGrid.markTileAt(IndexPath(row: rowIndex, section: colIndex))
                } else {
                    testGrid.selectTileAt(IndexPath(row: rowIndex, section: colIndex))
                }
            }
        }

        // Then
        let gameWon = testGrid.gameWon()

        XCTAssertTrue(gameWon)
    }

    func testCorrectlyRecognisesGameLostState() {
        // Given
        testGrid.newGame()

        // When
        for rowIndex in 0..<testGridRows {
            for colIndex in 0..<testGridCols {
                let tile = testGrid.tileAt(rowIndex, colIndex)

                if tile.isMine {
                    testGrid.selectTileAt(IndexPath(row: rowIndex, section: colIndex))
                }
            }
        }

        // Then
        let gameState = testGrid.getState()

        XCTAssert(gameState == .lost)
    }

    func testCorrectlyRecognisesGameInProgressState() {
        // Given
        testGrid.newGame()

        // When
        for rowIndex in 0..<testGridRows {
            for colIndex in 0..<testGridCols {
                let tile = testGrid.tileAt(rowIndex, colIndex)

                if !tile.isMine {
                    testGrid.selectTileAt(IndexPath(row: rowIndex, section: colIndex))
                }
            }
        }

        // Then
        let gameState = testGrid.getState()

        XCTAssert(gameState == .inProgress)
    }

    func testGridSetsTileAsShown() {
        // Given
        testGrid = Grid(rows: 3, columns: 3, mines: 0)
        testGrid.newGame()

        // When
        testGrid.selectTileAt(IndexPath(row: 0, section: 0))

        // Then
        let tile = testGrid.tileAt(0, 0)
        XCTAssert(tile.isShown)
    }

    func testGridMarksTiles() {
        // Given
        testGrid.newGame()

        // When
        testGrid.markTileAt(IndexPath(row: 0, section: 0))

        // Then
        let tile = testGrid.tileAt(0, 0)
        XCTAssert(tile.isMarked)
    }

    func testTileAtReturnsTheCorrectTile() {
        // Given
        testGrid = Grid(rows: 3, columns: 3, mines: 0)
        testGrid.newGame()

        // When
        testGrid.selectTileAt(IndexPath(row: 1, section: 1))

        // Then
        let tile = testGrid.tileAt(1, 1)
        XCTAssertEqual(tile.rowNum, 1)
        XCTAssertEqual(tile.colNum, 1)
    }

    func testTileReturnsTheCorrectTileForIndexPath() {
        // Given
        testGrid.newGame()

        // When
        let indexPath = IndexPath(row: 2, section: 2)
        let tile = testGrid.tileAt(indexPath: indexPath)

        // Then
        XCTAssert(tile.rowNum == 2)
        XCTAssert(tile.colNum == 2)
    }
}

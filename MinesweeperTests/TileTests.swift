//
//  TileTests.swift
//  MinesweeperTests
//
//  Created by Josh Maloney on 11/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import XCTest

@testable import Minesweeper

class TileTests: XCTestCase {
    var testTile: Tile!

    override func setUp() {
        testTile = Tile(isMine: false, surroundingMinesCount: 0, row: 0, col: 0)
    }

    override func tearDown() {
        testTile = nil
    }

    func testHiddenDisplayState() {
        // Given
        testTile.isShown = false
        testTile.isMine = true
        testTile.isMarked = false

        // Then
        XCTAssertEqual(testTile.currentDisplayState(), .hidden, "Unexpected display state")
    }
}

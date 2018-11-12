//
//  GameCollectionViewControllerTests.swift
//  MinesweeperTests
//
//  Created by Josh Maloney on 12/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import XCTest

@testable import Minesweeper

class GameCollectionViewControllerTests: XCTestCase {
    var window: UIWindow!
    var controller: GameCollectionViewController!
    var navigationController: UINavigationController!

    var testGame: Game!

    override func setUp() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        if let viewController = storyboard.instantiateViewController(
            withIdentifier: "GameCollectionViewController") as? GameCollectionViewController {

            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            testGame = Game(rows: 9, columns: 9, mines: 1)
            controller = viewController
            controller.game = testGame
            controller.loadViewIfNeeded()

            navigationController = UINavigationController(rootViewController: controller)
            navigationController.view.layoutIfNeeded()

            appDelegate?.window!.rootViewController = navigationController

            window = UIWindow()
            window.rootViewController = controller
            window.makeKeyAndVisible()
        }
    }

    override func tearDown() {
        window = nil
        controller = nil
        navigationController = nil
        testGame = nil
    }

    func testDoesDismissItselfOnSettingsClick() {
        controller.settingButtonPressed(UIButton())

        XCTAssertNil(controller.presentedViewController)
    }

    func testCollectionViewDataSource() {
        let rowCount = controller.numberOfSections(in: controller.collectionView)
        let colCount = controller.collectionView(controller.collectionView, numberOfItemsInSection: 1)

        XCTAssertEqual(rowCount, testGame.numRows)
        XCTAssertEqual(colCount, testGame.numColumns)
    }

    func getTestCell() -> GameCollectionViewCell {
        let indexPath = IndexPath(row: 0, section: 0)
        let collectionView = controller.collectionView!

        if let cell = controller.collectionView(collectionView, cellForItemAt: indexPath) as? GameCollectionViewCell {
            return cell
        }

        fatalError()
    }

    func testCellWithHiddenDisplay() {
        // Tile should be initially hidden
        let cell = getTestCell()
        XCTAssert(cell.gridCellLabel.text == "")
        XCTAssert(cell.backgroundColor == .lightGray)
    }

    func testCellWithMarkedDisplay() {
        // Tile should display marked
        let indexPath = IndexPath(row: 0, section: 0)
        controller.game.markTileAt(indexPath)

        let cell = getTestCell()
        XCTAssert(cell.gridCellLabel.text == "🍆")
        XCTAssert(cell.backgroundColor == .lightGray)
    }

    func testCellWithShownDisplay() {
        // Tile should display marked
        let indexPath = IndexPath(row: 0, section: 0)
        controller.game.selectTileAt(indexPath)

        let cell = getTestCell()
        XCTAssert(cell.gridCellLabel.text == "")
        XCTAssert(cell.backgroundColor == .white)
    }
}

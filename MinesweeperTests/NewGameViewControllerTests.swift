//
//  NewGameViewControllerTests.swift
//  MinesweeperTests
//
//  Created by Josh Maloney on 12/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import XCTest

@testable import Minesweeper

class NewGameViewControllerTests: XCTestCase {
    var window: UIWindow!
    var controller: NewGameViewController!
    var navigationController: UINavigationController!

    var testSlider: UISlider!

    override func setUp() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        if let viewController = storyboard
            .instantiateViewController(withIdentifier: "NewGameViewController") as? NewGameViewController {

            let appDelegate = UIApplication.shared.delegate as? AppDelegate

            controller = viewController
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
    }

    func testDefaultValuesAreCorrect() {
        XCTAssertEqual(controller.numRows, 9, "Default 9 Rows")
        XCTAssertEqual(controller.numColumns, 9, "Default 9 Columns")
        XCTAssertEqual(controller.numMines, 10, "Default 10 Mines")
    }

    func testDidChangeRowSlider() {
        controller.rowCountSlider.value = 5.0

        controller.rowSliderMoved(controller.rowCountSlider)

        XCTAssertEqual(controller.numRows, 5, "Row Slider")
        XCTAssertEqual(controller.rowCountLabel.text!, "5")
    }

    func testDidChangeColumnSlider() {
        controller.columnCountSlider.value = 5.0

        controller.columnSliderMoved(controller.columnCountSlider)

        XCTAssertEqual(controller.numColumns, 5, "Column Slider")
        XCTAssertEqual(controller.columnCountLabel.text!, "5")
    }

    func testDidChangeMineSlider() {
        controller.mineCountSlider.value = 5.0

        controller.mineSliderMoved(controller.mineCountSlider)

        XCTAssertEqual(controller.numMines, 5, "Mine Slider")
        XCTAssertEqual(controller.mineCountLabel.text!, "5")
    }

    func testPerformsSegue() {
        controller.performSegue(withIdentifier: "easyGameSegue", sender: nil)

        XCTAssertNotNil(controller.presentedViewController as? GameCollectionViewController)
    }
}

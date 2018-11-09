//
//  GridCollectionViewController.swift
//  Minesweeper
//
//  Created by Josh Maloney on 6/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SweeperCell"

enum GameState {
    case inProgress
    case fail
    case win
}

class GridCollectionViewController: UICollectionViewController,
        UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!

    // MARK: - Properties
    var numRows: Int = 0
    var numColumns: Int = 0
    var numMines: Int = 0

    var game = [[Tile]]()

    var gameState: GameState = .inProgress

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup CollectionViewFlowLayout to ensure there is no cell wrapping
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        self.collectionView.collectionViewLayout = flowLayout

        // Setup long press gesture on cells
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(GridCollectionViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)

        // Prevent accidental swiping back and cancelling game
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        setupGame()
        print("complete..")
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numColumns
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numRows
    }

    // Updates the cell at the specified indexPath
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let col = indexPath.section

        if gameState == .fail || gameState == .win {
            return
        }

        if game[row][col].isMine {
            gameState = .fail
            self.navigationItem.title = "😤"
            endGame()
            return
        }

        // No action if tile already shown
        if game[row][col].isShown {
            return
        }

        // Marking/Unmarking handle by long tap in handleLongPress
        if game[row][col].isMarked {
            return
        }

        // If the cell has not be previously revealed
        if game[row][col].surroundingMinesCount == 0 && !game[row][col].isMine {
            selectSurroundingCells(row, col)
            game[row][col].isShown = true

            collectionView.reloadData()
            return
        }

        game[row][col].isShown = true
        checkGameState()

        collectionView.reloadItems(at: [indexPath])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.bounds.size.height/CGFloat(numRows + 1) - 2,
            height: collectionView.bounds.size.height/CGFloat(numRows + 1) - 2
        )
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if let gridCell = cell as? GridCollectionViewCell {
            let row = indexPath.row
            let col = indexPath.section

            // Configure the cell
            if game[row][col].isMarked {
                gridCell.displayMarked()
            } else if game[row][col].isShown {
                if game[row][col].isMine {
                    gridCell.displayMine()
                } else {
                    gridCell.displayNumber(surroundingMines: game[row][col].surroundingMinesCount)
                }
            } else {
                gridCell.displayHidden()
            }

            return gridCell
        } else {
            return cell
        }
    }

    func selectSurroundingCells(_ row: Int, _ col: Int) {
        if game[row][col].isShown {
            return
        }

        game[row][col].isShown = true

        if game[row][col].surroundingMinesCount != 0 {
            return
        }

        // Check Top
        if row > 0 {
            // TopLeft
            if col > 0 {
                selectSurroundingCells(row - 1, col - 1)
            }

            // TopTop
            selectSurroundingCells(row - 1, col)

            // TopRight
            if col + 1 < numColumns {
                selectSurroundingCells(row - 1, col + 1)
            }
        }

        // Check Left
        if col > 0 {
            selectSurroundingCells(row, col - 1)
        }

        // Check Right
        if col + 1 < numColumns {
            selectSurroundingCells(row, col + 1)
        }

        // Check Down
        if row + 1 < numRows {
            // Bottom Left
            if col > 0 {
                selectSurroundingCells(row + 1, col - 1)
            }

            // Bottom Bottom
                selectSurroundingCells(row + 1, col)

            // Bottom Right
            if col + 1 < numColumns {
                selectSurroundingCells(row + 1, col + 1)
            }
        }
    }

    func checkGameState() {
        for row in 0..<numRows {
            for col in 0..<numColumns {
                if game[row][col].isMine && !game[row][col].isMarked {
                    return
                }

                if !game[row][col].isMine && !game[row][col].isShown {
                    return
                }
            }
        }

        gameState = .win
        self.navigationItem.title = "😍"
    }

    func endGame() {
        for row in 0..<numRows {
            for col in 0..<numColumns where game[row][col].isMine {
                game[row][col].isShown = true
            }
        }

        collectionView.reloadData()
    }

    @IBAction func newGamePressed(_ sender: Any) {
        gameState = .inProgress
        game = [[Tile]]()
        setupGame()
        collectionView.reloadData()
    }

    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if gameState == .win || gameState == .fail {
            return
        }
        
        if sender.state != UIGestureRecognizer.State.began {
            return
        }

        let touchLocation = sender.location(in: self.collectionView)

        if let indexPath: IndexPath = (self.collectionView?.indexPathForItem(at: touchLocation))! {
            let row = indexPath.row
            let col = indexPath.section

            if !game[row][col].isShown {
                game[row][col].isMarked = !game[row][col].isMarked
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }

    func setupGame() {
        self.navigationItem.title = "🤔"

        for _ in 0..<numRows {
            var row = [Tile]()

            for _ in 0..<numColumns {
                row.append(Tile(isMine: false, surroundingMinesCount: 0))
            }

            game.append(row)
        }

        placeMines()
        countMines()

        print("setup complete")
    }

    func placeMines() {

        var minesLeftToPlace = numMines

        while minesLeftToPlace > 0 {
            let randRow = Int.random(in: 0..<numRows)
            let randCol = Int.random(in: 0..<numColumns)

            // Check cell not already a mine
            if !game[randRow][randCol].isMine {
                game[randRow][randCol].isMine = true
                minesLeftToPlace -= 1
            }
        }
    }

    func countMines() {
        for row in 0..<numRows {
            for col in 0..<numColumns {
                var count: Int = 0

                // Check Top
                if row > 0 {
                    // TopLeft
                    if col > 0 && game[row - 1][col - 1].isMine {
                        count += 1
                    }

                    // TopTop
                    if game[row - 1][col].isMine {
                        count += 1
                    }

                    // TopRight
                    if col + 1 < numColumns && game[row - 1][col + 1].isMine {
                        count += 1
                    }
                }

                // Check Left
                if col > 0 && game[row][col - 1].isMine {
                    count += 1
                }

                // Check Right
                if col + 1 < numColumns && game[row][col + 1].isMine {
                    count += 1
                }

                // Check Down
                if row + 1 < numRows {
                    // Bottom Left
                    if col > 0 && game[row + 1][col - 1].isMine {
                        count += 1
                    }

                    // Bottom Bottom
                    if game[row + 1][col].isMine {
                        count += 1
                    }

                    // Bottom Right
                    if col + 1 < numColumns && game[row + 1][col + 1].isMine {
                        count += 1
                    }
                }

                game[row][col].surroundingMinesCount = count
            }
        }
    }
}

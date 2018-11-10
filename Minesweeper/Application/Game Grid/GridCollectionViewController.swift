//
//  GridCollectionViewController.swift
//  Minesweeper
//
//  Created by Josh Maloney on 6/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SweeperCell"

class GridCollectionViewController: UIViewController, UIGestureRecognizerDelegate, GameControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gameStateButton: UIButton!
    @IBOutlet weak var totalSecondsLabel: UILabel!
    @IBOutlet weak var minesRemainingLabel: UILabel!
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!

    // MARK: - Properties
    var game: Game!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard game != nil else {
            dismiss(animated: true, completion: nil)
            return
        }

        // Prevent accidental swiping back and cancelling game
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        collectionView.delegate = self
        collectionView.dataSource = self
        game.delegate = self

        setupGame()
    }

    // MARK: - Game Initialisers
    @IBAction func settingButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func newGamePressed(_ sender: Any) {
        game.reset()
        updateMinesMarkedCount()
        collectionView.reloadData()
    }

    func setupGame() {
        game.setup()
        updateMinesMarkedCount()
    }

    // MARK: - View Updaters
    func gameSecondsCountDidUpdate(game: Game, withTotalSeconds: Int) {
        totalSecondsLabel.text = "\(withTotalSeconds)"
    }

    func updateMinesMarkedCount() {
        minesRemainingLabel.text = "\(game.getRemainingMines())"
    }

    func gameStateDidUpdate(game: Game, withState state: GridState) {
        print(state)
        switch state {
        case .won:
            gameStateButton.titleLabel?.text = "😍"
        case .lost:
            gameStateButton.titleLabel?.text = "😤"
            collectionView.reloadData()
        case .inProgress:
            gameStateButton.titleLabel?.text = "🤔"
        case .notStarted:
            gameStateButton.titleLabel?.text = "🤔"
        }
    }

    // MARK: - Gesture Handlers
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began {
            return
        }

        let touchLocation = sender.location(in: collectionView)

        if let indexPath: IndexPath = (collectionView.indexPathForItem(at: touchLocation)) {
            game.markTileAt(indexPath)

            updateMinesMarkedCount()
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - CollectionView Delegate and Datasource extensions
extension GridCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    // Updates the cell at the specified indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        game.selectTileAt(indexPath)

        collectionView.reloadData()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.frame.height/CGFloat(game.numRows + 1),
            height: collectionView.frame.height/CGFloat(game.numRows + 1)
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if let gridCell = cell as? GridCollectionViewCell {
            let tile = game.getTileForCellAt(indexPath: indexPath)

            switch tile.currentDisplayState() {
            case .marked:
                gridCell.displayMarked()
            case .hidden:
                gridCell.displayHidden()
            case .mine:
                gridCell.displayMine()
            case .number:
                gridCell.displayNumber(surroundingMines: tile.surroundingMinesCount)
            }

            return gridCell
        }

        return cell
    }

    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return game.numColumns
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.numRows
    }
}

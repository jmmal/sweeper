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

    // MARK: - Properties
    var game: Game?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup CollectionViewFlowLayout to ensure there is no cell wrapping
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0

        // Setup long press gesture on cells
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(GridCollectionViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        lpgr.allowableMovement = CGFloat(2)
        self.collectionView?.addGestureRecognizer(lpgr)

        // Prevent accidental swiping back and cancelling game
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = flowLayout
        game?.delegate = self

        setupGame()
    }

    func gameSecondsCountDidUpdate(game: Game, withTotalSeconds: Int) {
        totalSecondsLabel.text = "\(withTotalSeconds)"
    }

    func updateMinesMarkedCount() {
        if let mineCount = game?.getRemainingMines() {
            minesRemainingLabel.text = "\(mineCount)"
        }
    }

    func gameStateDidUpdate(game: Game, withState state: GridState) {
        print("gameStateUpdatred")

        switch state {
        case .won:
            gameStateButton.titleLabel?.text = "😍"
        case .lost:
            gameStateButton.titleLabel?.text = "😤"
            collectionView.reloadData()
        case .inProgress:
            gameStateButton.titleLabel?.text = "🤔"
        case .notStarted:
            gameStateButton.titleLabel?.text = "👀"
        }
    }

    @IBAction func settingButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func newGamePressed(_ sender: Any) {
        game?.reset()
        updateMinesMarkedCount()
        collectionView.reloadData()
    }

    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began {
            return
        }

        let touchLocation = sender.location(in: collectionView)

        if let indexPath: IndexPath = (collectionView.indexPathForItem(at: touchLocation)) {
            game?.markTileAt(indexPath)

            updateMinesMarkedCount()
            collectionView.reloadItems(at: [indexPath])
        }
    }

    func setupGame() {
        game?.setup()

        gameStateButton.titleLabel?.text = "🤔"
        updateMinesMarkedCount()
    }
}

extension GridCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    // Updates the cell at the specified indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        game?.selectTileAt(indexPath)

        collectionView.reloadData()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let currentGame = game {
            return CGSize(
                width: collectionView.frame.height/CGFloat(currentGame.numRows + 1),
                height: collectionView.frame.height/CGFloat(currentGame.numRows + 1)
            )
        }

        return CGSize(width: 20, height: 20)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if let gridCell = cell as? GridCollectionViewCell {
            if let tile = game?.getTileForCellAt(indexPath: indexPath) {
                switch tile.displayState() {
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
        }

        return cell
    }

    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return game?.numColumns ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game?.numRows ?? 0
    }
}

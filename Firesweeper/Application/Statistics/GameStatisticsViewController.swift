//
//  GameStatisticsViewController.swift
//  Minesweeper
//
//  Created by Josh Maloney on 12/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.

import UIKit
import CoreData

class GameStatisticsViewController: UIViewController {
    var managedContext: NSManagedObjectContext!

    private var easyGames: [GameStatistic] = []
    private var mediumGames: [GameStatistic] = []
    private var hardGames: [GameStatistic] = []
    private var customGames: [GameStatistic] = []

    @IBOutlet weak var easyGamesLabel: UILabel!
    @IBOutlet weak var mediumGamesLabel: UILabel!
    @IBOutlet weak var hardGamesLabel: UILabel!
    @IBOutlet weak var customGamesLabel: UILabel!

    @IBOutlet weak var easyTimeLabel: UILabel!
    @IBOutlet weak var mediumTimeLabel: UILabel!
    @IBOutlet weak var hardTimeLabel: UILabel!
    @IBOutlet weak var customTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        managedContext =
            appDelegate.persistentContainer.viewContext

        easyGames = fetchEasyGames()
        mediumGames = fetchMediumGames()
        hardGames = fetchHardGames()
        customGames = fetchCustomGames()

        let totalEasyWon = getWon(easyGames)
        let totalMedWon = getWon(mediumGames)
        let totalHardWon = getWon(hardGames)
        let totalCustomWon = getWon(customGames)

        let fastestEasy = getFastest(forGames: totalEasyWon)
        let fastestMedium = getFastest(forGames: totalMedWon)
        let fastestHard = getFastest(forGames: totalHardWon)
        let fastestCustom = getFastest(forGames: totalCustomWon)

        easyGamesLabel.text = "\(easyGames.count), \(totalEasyWon.count)"
        mediumGamesLabel.text = "\(mediumGames.count), \(totalMedWon.count)"
        hardGamesLabel.text = "\(hardGames.count), \(totalHardWon.count)"
        customGamesLabel.text = "\(customGames.count), \(totalCustomWon.count)"

        easyTimeLabel.text = "\(fastestEasy?.totalTime ?? 999)s"
        mediumTimeLabel.text = "\(fastestMedium?.totalTime ?? 999)s"
        hardTimeLabel.text = "\(fastestHard?.totalTime ?? 999)s"
        customTimeLabel.text = "\(fastestCustom?.totalTime ?? 999)s"
    }

    func getFastest(forGames games: [GameStatistic]) -> GameStatistic? {
        return games.min { (left, right) -> Bool in
            return left.totalTime < right.totalTime
            }

    }

    func getWon(_ games: [GameStatistic]) -> [GameStatistic] {
        var result: [GameStatistic] = []

        for stat in games where stat.gameStatus == GameStatType.won.rawValue {
            result.append(stat)
        }

        return result
    }

    func printGames(_ games: [GameStatistic]) {
        for stat in games {
            print("won? \(stat.gameStatus == GameStatType.won.rawValue) \(stat.gameStatus) \(stat.totalTime)s")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    private func fetchEasyGames() -> [GameStatistic] {
        let predicate = NSPredicate(format: "gameType == %@", argumentArray: [GameType.easy.rawValue])
        return fetchGames(withPredicate: predicate)
    }

    private func fetchMediumGames() -> [GameStatistic] {
        let predicate = NSPredicate(format: "gameType == %@", argumentArray: [GameType.medium.rawValue])
        return fetchGames(withPredicate: predicate)
    }

    private func fetchHardGames() -> [GameStatistic] {
        let predicate = NSPredicate(format: "gameType == %@", argumentArray: [GameType.hard.rawValue])
        return fetchGames(withPredicate: predicate)
    }

    private func fetchCustomGames() -> [GameStatistic] {
        let predicate = NSPredicate(format: "gameType == %@", argumentArray: [GameType.custom.rawValue])
        return fetchGames(withPredicate: predicate)
    }

    private func fetchGames(withPredicate predicate: NSPredicate) -> [GameStatistic] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameStatistic")
        fetchRequest.predicate = predicate

        var fetchResult: [AnyObject] = []
        do {
            fetchResult = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        guard let result = fetchResult as? [GameStatistic] else {
            return []
        }

        return result
    }
}

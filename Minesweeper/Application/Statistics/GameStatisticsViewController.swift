//
//  GameStatisticsViewController.swift
//  Minesweeper
//
//  Created by Josh Maloney on 12/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import UIKit
import CoreData

class GameStatisticsViewController: UIViewController {
    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var columnLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var statistics: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext

        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "GameStatistic")

        //3
        do {
            statistics = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        for stat in statistics {
            if let stat = stat as? GameStatistic {
                print("Row: \(stat.rowSize), Col: \(stat.colSize), Time: \(stat.totalTime), Type: \(stat.gameStatus)")
            }
        }
    }
}

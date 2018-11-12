//
//  GameStats.swift
//  Minesweeper
//
//  Created by Josh Maloney on 12/11/18.
//  Copyright © 2018 Josh Maloney. All rights reserved.
//

import Foundation
import RealmSwift

class GameStats: Object {
    @objc dynamic var rowSize: Int = 0
    @objc dynamic var colSize: Int = 0
    @objc dynamic var totalTime: Int = 0
}

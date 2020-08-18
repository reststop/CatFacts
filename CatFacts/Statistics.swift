//
//  Statistics.swift
//  CatFacts
//
//  Created by carl on 8/17/20.
//  Copyright © 2020 Catalyst Art. All rights reserved.
//

import Foundation

class Statistics {

    static let shared = Statistics()
    private init() {}

    var  statistics : [Statistic] = []

    //
    // Note: you see a number of strings that ought to be constants
    //       I left them as constants so I didn't have to deal with
    //       syntax changes, an improvement would be to remove all
    //       the strings and replace them with constants everywhere
    //

    class func reset() {
        // print("Statistics reset")
        self.shared.statistics = []
        self.shared.statistics.append(Statistic(type: .once, name: "Device model", value: Information.modelName))
        self.shared.statistics.append(Statistic(type: .once, name: "OS Version", value: Information.osVersion()))
        self.shared.statistics.append(Statistic(type: .once, name: "App Version", value: Information.appVersion()))

        NotificationCenter.default.post(name: .statisticsUpdated, object: nil)
    }

    //
    // function to search table for statand add it if not found
    //
    class func find(name: String, theStat: Statistic) {
        var found : Bool = false
        // see if statistic already exists
        for stat in Statistics.shared.statistics {
            if stat.name == name {
                // found it
                found = true
                break
            }
        }
        // if it wasn't found, create it and save it
        if !found {
            Statistics.shared.statistics.append(theStat)
            NotificationCenter.default.post(name: .statisticsUpdated, object: nil)
        }
    }

    class func update(name: String, value: String) {
        var found : Bool = false
        for stat in Statistics.shared.statistics {
            if stat.name == name {
                // found it
                found = true
                stat.setValue(value)
                break
            }
        }
        if !found {
            let stat = Statistic(type: .current, name: name, value: value)
            Statistics.find(name: name, theStat: stat)
        }
        NotificationCenter.default.post(name: .statisticsUpdated, object: nil)
    }

}

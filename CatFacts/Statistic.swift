//
//  Statistic.swift
//  CatFacts
//
//  Created by carl on 8/17/20.
//  Copyright © 2020 Catalyst Art. All rights reserved.
//

import Foundation

// once    - static data, one gathered, use as-is, such as device.model
// current - current data, can change such as device.orientation
// average - keeps a count, total and last to get avg=total/count
// total   - cumulative, keeps a count in case you want an average
//
enum StatType {
    case once, current, average, total
}

//
// Note: This was initially a struct, but we needed persistence and
//       the ability to have multiple pointers to the same struct
//       so it was converted to a class :-(
//

class Statistic {
    var type : StatType
    var name : String
    var value : String
    var count : Int32 = 0
    var total : Double = 0.0
    var average : Double = 0.0
    var last : Double = 0.0

    init(type: StatType, name: String, value: String) {
        self.type = type
        self.name = name
        self.value = value
    }

    init(type: StatType, name: String, value: String, count: Int32, total: Double, average: Double, last: Double) {
        self.type = type
        self.name = name
        self.value = value
        self.count = count
        self.total = total
        self.average = average
        self.last = last
    }

    //
    // Initial values aside, most updates will be by setValue
    //
    // the work of averaging or summation is done as each value
    // is added, so that by type, the correct info can simply
    // be retrieved when wanted, no math involved, and no worries
    // about how many entries there are
    //

    // a future enhancement might be to send a message to the
    // statistic view controller to reload the table via
    // NSNotification or some other means....

    func setValue(_ value: String) {
        // ignore empty values
        // if you want to add "0.0", then do it explicitly
        if value == "" {
            return
        }
        switch self.type {
        case .once:
            self.value = value
        case .current:
            self.value = value
            self.last = Double(value) ?? 0.0
        case .average, .total:
            self.last = Double(value) ?? 0.0
            self.count += 1
            self.total += self.last
            if self.type == .average {
                // if we think we shall ever need more than an Int32, then change
                // count to a Double, and update the average calculation below
                self.average = self.total / Double(self.count)
            }
//
// the switch is exhaustive, so default: will never be executed
// if this changes, this is the default code
//
//        default:
//            self.value = value
//            self.last = Double(value) ?? 0.0
//
        }
    }

}


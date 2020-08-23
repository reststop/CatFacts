//
//  StatisticViewController.swift
//  CatFacts
//
//  Created by carl on 8/16/20.
//  Copyright © 2020 Catalyst Art. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let statisticsUpdated = Notification.Name("statistcs updated")
}

class StatisticViewCell : UITableViewCell {

    // labels spaced differently than default cell
    @IBOutlet var statName: UILabel!
    @IBOutlet var statValue: UILabel!
    @IBOutlet var statCount: UILabel!
    @IBOutlet var statAverage: UILabel!
    @IBOutlet var statLast: UILabel!

}


class StatisticViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    static let statisticsUpdated = Notification.Name("")

    @IBOutlet var statisticsTable : UITableView!

    let PLACEHOLDER_NAME = "unknown"
    var count = 1

    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "statistic"


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // check if Statistics setup already
        //
        if Statistics.shared.statistics.count == 0 {
            Statistics.reset()
        }

        // Update memory usage for current display
        Statistics.update(name: "Current Memory", value: Information.megabytesUsed())


        // make tbleview clear
        self.statisticsTable.backgroundColor = UIColor.clear

        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.statisticsTable.tableFooterView = UIView()

        // This view controller itself will provide the delegate
        // methods and row data for the table view.
        self.statisticsTable.delegate = self
        self.statisticsTable.dataSource = self
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view.

        self.statisticsTable.reloadData()

        // set observer for notifications of table updates
        NotificationCenter.default.addObserver(self, selector: #selector(statisticsUpdated(_:)), name: .statisticsUpdated, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @objc func statisticsUpdated(_: Notification) {
        DispatchQueue.main.async{
            self.statisticsTable.reloadData()
        }
    }

    // number of rows in tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Statistics.shared.statistics.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! StatisticViewCell

        cell.backgroundColor = UIColor.clear

        let row = indexPath.row
        let stats : [Statistic] = Statistics.shared.statistics
        if row < stats.count {
            // set the text from the data model
            cell.statName.text = stats[row].name
            switch stats[row].type {
            case .once, .current:
                cell.statValue.text = stats[row].value
            case .average, .total:
                cell.statCount.text = String(format:"Cnt: %d", stats[row].count)
                cell.statAverage.text = String(format:"Avg: %.3f", stats[row].average)
                cell.statLast.text = String(format:"Last: %.3f", stats[row].last)
                if stats[row].type == .total {
                    cell.statValue.text = String(format:"Total: %.3f", stats[row].total)
                }
                else {
                    cell.statValue.text = ""
                }
            }
        }
        else {
            cell.statName.text = PLACEHOLDER_NAME
        }
        return cell

    }

}


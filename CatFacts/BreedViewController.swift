//
//  BreedViewController.swift
//  CatFacts
//
//  Created by carl on 8/16/20.
//  Copyright © 2020 Catalyst Art. All rights reserved.
//

import UIKit

class BreedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let PLACEHOLDER_NAME = "...loading..."

    let managementTime : TimeInterval = 5
    var dataTimer : Timer? = nil
    var selectedBreed : Breed? = nil
    var lastDisplayedIndexPath : IndexPath = IndexPath(row: 0, section: 0)

    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "breed"

    var breeds : [Breed?] = []

    @IBOutlet var breedTable : UITableView?

    var activity : UIActivityIndicatorView = UIActivityIndicatorView()

    func loadBreeds(page: Int) -> Void {
        self.activity.startAnimating()
        BreedData.fetchPage(myPage: page, completion: { (from, results, error) in
          if error == nil {
            var index = from - 1
            for element in results {
                // if we are expanding breeds using .append at any index
                if self.breeds.count == index {
                    self.breeds.append(element)
                    // try reloading only updated rows
                    DispatchQueue.main.async{
                        self.breedTable?.reloadData()
                    }
                }
                else {
                    // if we are refreshing or replacing existing index
                    // it might have been change to nil, or same data
                    if self.breeds.count > index {
                        self.breeds[index] = element
                        DispatchQueue.main.async{
                            self.breedTable?.reloadData()
                        }
                    }
                    else {
                        // we seem to be someplace else
                        // let's ignore this for now
                        print("Attempt to insert to breeds at \(index) while \(self.breeds.count) entries")
                    }
                }
                index += 1
            }

            Statistics.update(name: "Total Cat Breeds", value: String(self.breeds.count))
            if self.breeds.count < BreedData.totalBreeds {
                // add a fake empty record if there's still more to come
                self.breeds.append(nil)
            }
          }
          else {
            DispatchQueue.main.async{

                // we got an error
                print("----We got an error:----")
                print(error as Any)
                let alert = UIAlertController(title: "Error:", message: (error?.localizedDescription ?? "Unknown Internet Error") as String, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                self.present(alert, animated: true)
                }
            }
        })

        self.activity.stopAnimating()
        self.breedTable?.reloadData()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // add activity indicator to view
        self.activity.frame = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 60.0)
        self.activity.center = self.view.center
        self.activity.hidesWhenStopped = true
        self.activity.style = .large
        self.view.addSubview(self.activity)
        self.activity.stopAnimating()

        // initialize Statistics before we do anything else so when we```
        // switch to the Statistics tab, prior data will be collected
        // but only do this if the statistics array is empty
        //
        if Statistics.shared.statistics.count == 0 {
            Statistics.reset()
        }

        // Register the table view cell class and its reuse id
        self.breedTable?.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.breedTable?.tableFooterView = UIView()

        // This view controller itself will provide the delegate
        // methods and row data for the table view.
        self.breedTable?.delegate = self
        self.breedTable?.dataSource = self

        // initially breeds array will be empty
        // while testing, it contains some canned data
        if breeds.count == 0 {
            self.loadBreeds(page: 1)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view.

        self.breedTable?.reloadData()

//        while self.breeds.count < BreedData.totalBreeds {
//            self.loadBreeds(page: 0)
//        }

        // may want to set a timer, and have the timer load or
        // manage the array of breeds
        Timer.scheduledTimer(withTimeInterval: managementTime, repeats: true, block: { timer in
            // save this so if view disappears it can be removed
            self.dataTimer = timer
            self.manageBreedTable()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // invalidate any timers
        if self.dataTimer != nil {
            self.dataTimer?.invalidate()
        }
    }

    func manageBreedTable() {
        // handle initial loading by pages
        if self.breeds.count < BreedData.totalBreeds {
            let page = Int(self.breeds.count / BreedData.pageSize) + 1
            self.loadBreeds(page: page)
        }

    }


    // number of rows in tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breeds.count
    }

    // create a cell or reuse a previous cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) 

        let row = indexPath.row
        self.lastDisplayedIndexPath = indexPath
        if row < self.breeds.count
            && self.breeds[row] != nil {
            // set the text from the data model
            cell.textLabel?.text = self.breeds[row]?.breed
        }
        else {
            cell.textLabel?.text = PLACEHOLDER_NAME
        }
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedBreed = breeds[indexPath.row]
        performSegue(withIdentifier: "breedDetail", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "breedDetail" {
            let vc = segue.destination as! BreedDetailViewController
            vc.selectedBreed = self.selectedBreed
            // Do I really need to do anything here,
            // if my view controller references the
            //      presenting view controller?
            //

        }
    }

}






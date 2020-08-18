//
//  BreedDetailViewController.swift
//  CatFacts
//
//  Created by carl on 8/16/20.
//  Copyright © 2020 Catalyst Art. All rights reserved.
//

import UIKit

class BreedDetailViewController: UIViewController {

    var selectedBreed : Breed? = nil

    @IBOutlet var breedName: UILabel!
    @IBOutlet var breedCoat: UILabel!
    @IBOutlet var breedCountry: UILabel!
    @IBOutlet var breedOrigin: UILabel!
    @IBOutlet var breedPattern: UILabel!



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


        if self.selectedBreed != nil {
            self.breedName.text = selectedBreed?.breed
            self.breedCoat.text = selectedBreed?.coat
            self.breedCountry.text = selectedBreed?.country
            self.breedOrigin.text = selectedBreed?.origin
            self.breedPattern.text = selectedBreed?.pattern
        }
        else {
            self.breedName.text = "...waiting..."
            self.breedCoat.text = ""
            self.breedCountry.text = ""
            self.breedOrigin.text = ""
            self.breedPattern.text = ""
        }
    }

    @IBAction func doneActionButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}


//
//  Breed.swift
//  CatFacts
//
//  Created by carl on 8/17/20.
//  Copyright © 2020 Catalyst Art. All rights reserved.
//

import Foundation

// defined here so it can be referenced in
// all view controllers and anything else
// which wants to operate on a Breed

struct Breed : Codable {
    var breed: String = ""
    var coat: String = ""
    var country: String = ""
    var origin: String = ""
    var pattern: String = ""
}

// no functions as yet



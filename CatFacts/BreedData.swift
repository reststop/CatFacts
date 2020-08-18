//
//  BreedData.swift
//  CatFacts
//
//  Created by carl on 8/18/20.
//  Copyright © 2020 Catalyst Art. All rights reserved.
//

import Foundation

class BreedData {

    //
    // this module basically retrieves the breed data
    // from https://catfact.ninja and maintains that
    // data: caching, refreshing, and fetching it when
    // necessary
    //
    //
    // with such a small amount of total data, the best
    // user experinece is to keep it in memory once it
    // is retrieved.  However, that doesn't permit the
    // caching or re-fetching that might be necessary
    // for a larger amount of data.
    //
    //

    //
    // things we need to parse the JSON
    //

    // the data returned in the JSON from catfact.ninja
    //
    fileprivate struct myBreeds: Codable {
        let current_page : Int
        let data : [Breed]
        let first_page_url : String
        let from : Int
        let last_page : Int
        let last_page_url : String
        let next_page_url : String?
        let path : String
        let per_page : String
        let prev_page_url : String?
        let to : Int
        let total : Int
    }

    static let baseURL = "https://catfact.ninja/breeds"
    static let pageSize = 8

    static var totalBreeds : Int = 0

    class func fetchPage(myPage: Int, completion: @escaping (Int, [Breed], Error?) -> Void) {

        // make sure the statistic is setup
        let statName = "Page Update"
        Statistics.find(name: statName,
            theStat: Statistic(type: .average, name: statName, value: "0.0"))

        let urlString = String(format:"%@?limit=%d&page=%d", baseURL, pageSize, myPage)
        if let url = URL(string: urlString) {
            let begin = NSDate.now
            URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
              if error == nil {
                let timer = NSDate.now
                let statData = String(format: "%.3f", timer.timeIntervalSince(begin) * 1000.0)
                Statistics.update(name: statName, value: statData)
                if let data = data {
                  do {
                    let res = try JSONDecoder().decode(myBreeds.self, from: data)
                    let theBreeds : [Breed] = res.data
                    totalBreeds = res.total
                    completion(res.from, theBreeds, error)

                  } catch let error {
                     print(error)
                  }
               }
              }
              else {
                completion(0, [], error)
              }
           }).resume()
        }
    }


    class func fetchElement(entry: Int, completion: @escaping (Int, [Breed]) -> Void) {

        // make sure the statistic is setup
        let statName = "Element Update"
        Statistics.find(name: statName,
                theStat: Statistic(type: .average, name: statName, value: "0.0"))

        let urlString = String(format:"%@?limit=%d&page=%d", baseURL, 1, entry)
        if let url = URL(string: urlString) {
            let begin = NSDate.now
            URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                let timer = NSDate.now
                let statData = String(format: "%.3f", timer.timeIntervalSince(begin) * 1000.0)
                Statistics.update(name: statName, value: statData)
                if let data = data {
                  do {
                    let res = try JSONDecoder().decode(myBreeds.self, from: data)
                    let theBreeds : [Breed] = res.data
                    totalBreeds = res.total
                    completion(res.from, theBreeds)

                  } catch let error {
                     print(error)
                  }
               }
           }).resume()
        }
    }





}

//
//  PPLeaderboardService.swift
//  Helloworld-Swift-SDK
//
//  Created by Gary J. Baldwin on 9/15/18.
//  Copyright © 2018 Gary J. Baldwin. All rights reserved.
//

import Foundation


class PPLeaderboardService {
    // This class provides all leaderboard

    
    init() {}

    //    GET /leaderboard/v1
    //
    // REQUEST
    // query: {
    //   page?: Number,
    //   limit?: Number,
    //   categories?: Comma separated String list
    // },
    // headers: {
    //   accesstoken: String
    // }
    //
    // RESPONSE
    // body: {
    //   total: Number,
    //   limit: Number,
    //   page: Number,
    //   pages: Number,
    //   docs: [{
    //     user: String,
    //     score: String,
    //     rank: Number,
    //     categories: [String]
    //   }]
    // }
    func getLeaderboard(page: Int, limit: Int, categories: String, completion: @escaping PPDataCompletion) {
        print("getLeaderboard: \(page) for categories: \( categories )" )
        
        PPManager.sharedInstance.PPwebapi.getLeaderboard(page: page, limit: limit, categories: categories) { succeeded, response, responseObject in
            if(succeeded) {
                print("getLeaderboard response: \(String(describing: response ))" )
                print("getLeaderboard responseObject: \(String(describing: responseObject ))" )
                completion(true, response, responseObject)
            } else {
                completion(false, response, nil)
            }
        }
    }
    
    // ===================================
    // POST /leaderboard/v1
    //
    // REQUEST
    // body: {
    //   score: Number,
    //   categories: [String]
    // },
    // headers: {
    //   accesstoken: String
    // }
    //
    // RESPONSE
    // body: {
    //   total: Number,
    //   limit: Number,
    //   page: Number,
    //   pages: Number,
    //   docs: [{
    //     user: String,
    //     score: String,
    //     rank: Number,
    //     categories: [String]
    //   }]
    // }
    
    func updateLeaderboard(score: NSNumber, categories: [String], completion: @escaping PPDataCompletion) {
        print("updateLeaderboard: \(score) for categories: \( categories )" )
        
        PPManager.sharedInstance.PPwebapi.updateLeaderboard(score: score, categories: categories) { succeeded, response, responseObject in
            if(succeeded) {
                print("updateLeaderboard response: \(String(describing: response ))" )
                print("updateLeaderboard responseObject: \(String(describing: responseObject ))" )
                completion(true, response, responseObject)
            } else {
                completion(false, response, nil)
            }
        }
    }
    

}

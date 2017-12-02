//
//  Trend.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 26/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

class Trend: NSObject {
    
    var name : String?
    var query : String?
    var tweetVolume : Int64?
    
    override init() {
        
    }
    
    init(savedTrend : SavedTrend?){
        name = savedTrend?.name
        query = savedTrend?.query
    }

}

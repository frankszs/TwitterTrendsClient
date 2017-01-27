//
//  Client.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 22/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

class Client: NSObject {
    
    static var sharedInstance = Client()
    static let consumerKey = "0h6iMHHYBwjhkSaQwX0JMH9se"
    static let consumerSecret = "mySKYHWMHgX4soJi9e8MpocrU7XVlR1ztYSmKOadiivxWwoG3N"
    
    var twitterAppOnlyAPI : STTwitterAPI
    
    override init(){
        
        self.twitterAppOnlyAPI = STTwitterAPI.init(appOnlyWithConsumerKey:Client.consumerKey, consumerSecret: Client.consumerSecret)
        
    }
    
    //MARK: GET Methods
    func getTopTrends(WOEID : String, amount : Int = 10, success : @escaping ([Trend]) -> Void, failure : @escaping (NSError) -> Void){
        
        self.twitterAppOnlyAPI.verifyCredentials(userSuccessBlock: { (user, id) in
            //Retrive JSON data.
            self.twitterAppOnlyAPI.getTrendsForWOEID(WOEID, excludeHashtags: NSNumber.init(value: 0), successBlock: {(currentDate, createdDate, locations, trends) in
                
                guard let trends = trends else { return }
          
                var trendObjects = [Trend]()
    
                //Parse trends into Trend objects.
                for (index, object) in trends.enumerated(){
                    //Max amount check.
                    if index >= amount { break }
                    
                    let trend = Trend()
                    if let trendJson = object as? Dictionary<String, Any>{
                        trend.name = trendJson["name"] as? String
                        trend.query = trendJson["query"] as? String
                        trendObjects.append(trend)
                    }
                }
                
                //Run closure with trend objects.
                success(trendObjects);
                
                }, errorBlock: {(error) in failure(error as! NSError);  print("errror \(error?.localizedDescription)")})
            }) { (error) in
        }
    }
    
    func getSearchTweets(searchText : String, amount : Int = 10, success : @escaping ([Tweet]) -> Void, failure : @escaping (NSError) -> Void){
        
        self.twitterAppOnlyAPI.verifyCredentials(userSuccessBlock: { (user, id) in
            
            //Retrive JSON data.
            self.twitterAppOnlyAPI.getSearchTweets(withQuery: searchText, successBlock: { (metaData, tweets) in
                
                guard let tweets = tweets else { return }
                
                var tweetObjects = [Tweet]()
                
                //Parse tweets into Tweet objects.
                for tweet in tweets as! [NSDictionary]{
                    let tweetObject = Tweet()
                    tweetObject.text = tweet.value(forKey: "text") as! String?;
                    tweetObject.retweetCount = Int(tweet.value(forKey: "retweet_count") as! NSNumber);
                    tweetObject.favoriteCount = Int(tweet.value(forKey: "favorite_count") as! NSNumber);
                    tweetObjects.append(tweetObject)
                }
                
                print(tweetObjects)
            
                //Run closure bl with tweets.
                success(tweetObjects);
                
                }, errorBlock: { (error) in failure(error as! NSError);  print("errror \(error?.localizedDescription)")})
            
            }) { (error) in
        }
    }

}

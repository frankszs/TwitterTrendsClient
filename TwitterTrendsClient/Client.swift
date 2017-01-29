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
    
    //Stores links as keys and images as values.
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    override init(){
        
        self.twitterAppOnlyAPI = STTwitterAPI.init(appOnlyWithConsumerKey:Client.consumerKey, consumerSecret: Client.consumerSecret)
    }
    
    //MARK: - GET Methods
    
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
                    
                    if let trend = self.parseTrend(dictionary: object as? NSDictionary){
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
            self.twitterAppOnlyAPI.getSearchTweets(withQuery: searchText, geocode: nil, lang: nil, locale: nil, resultType: nil, count: "50", until: nil, sinceID: nil, maxID: nil, includeEntities: nil, callback: nil, useExtendedTweetMode: nil, successBlock: { (metaData, tweets) in
                
                guard let tweets = tweets else { return }
                
                var tweetObjects = [Tweet]()
                
                //Parse tweets into Tweet objects.
                for object in tweets as! [NSDictionary]{
                    
                    if let tweet = self.parseTweet(dictionary: object){
                        tweetObjects.append(tweet)
                    }
                }
            
                //Run closure with tweets.
                success(tweetObjects);
                
                }, errorBlock: { (error) in failure(error as! NSError);  print("errror \(error?.localizedDescription)")})
            
            }) { (error) in
        }
    }
    
    //MARK: - Parse Methods
    
   private func parseTrend(dictionary : NSDictionary?) -> Trend?{
        
        guard let dictionary = dictionary else { return nil }
        
        let trend = Trend()
        trend.name = dictionary["name"] as? String
        trend.query = dictionary["query"] as? String
       
        return trend
    }
    
    private func parseTweet(dictionary : NSDictionary?) -> Tweet?{
        
        guard let dictionary = dictionary else { return nil }
        
        let tweet = Tweet()
        tweet.text = dictionary.value(forKey: "text") as! String?;
        tweet.retweetCount = Int(dictionary.value(forKey: "retweet_count") as! NSNumber);
        tweet.favoriteCount = Int(dictionary.value(forKey: "favorite_count") as! NSNumber);
        
        tweet.user = parseUser(dictionary: (dictionary.value(forKey: "user") as! NSDictionary?))
        
        return tweet
    }
    
    private func parseUser(dictionary : NSDictionary?) -> User?{
        
        guard let dictionary = dictionary else { return nil }
        
        let user = User()
        user.name = dictionary.value(forKey: "name") as! String?
        user.screenName = dictionary.value(forKey: "screen_name") as! String?
        user.profileImageLink = dictionary.value(forKey: "profile_image_url_https") as! String?
        
        return user
    }
}

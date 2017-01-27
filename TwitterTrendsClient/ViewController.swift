//
//  ViewController.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 17/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

protocol TweetCacheProtocol{
    
    func updateCache(tweets : [Tweet], for trend : Trend)
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    let trendCellID = "trendCell"
    
    @IBOutlet var tableView : UITableView!
    var refreshControl : UIRefreshControl!

    var trends : [Trend]?
    var tweetCache: NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = self.refreshControl
        tableView.backgroundColor = UIColor.white
        
        self.reloadData()
        
    }
    
    func reloadData(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Client.sharedInstance.getTopTrends(WOEID: "23424977", amount: 30, success: {trends in
            self.trends = trends
            
            //Reconstruct cache.
            self.tweetCache = NSMutableDictionary()
            for trend in self.trends!{
                Client.sharedInstance.getSearchTweets(searchText: trend.query!, amount: 20, success: {tweets in self.tweetCache?.setObject(tweets, forKey: trend.name! as NSCopying)}, failure: {error in})
            }
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            }, failure: {error in
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }})
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ToTweets"{
            
            if let trendCell = sender as? TrendCell{
                let destinationController = segue.destination as! TweetsController
                destinationController.trend = trendCell.trend
                let tweets = self.tweetCache?.object(forKey: trendCell.trend!.name!) as! [Tweet]?
                destinationController.tweets = tweets
                destinationController.cacheDelegate = self
                
            }
        }
    }
}

extension ViewController : TweetCacheProtocol{
    
    func updateCache(tweets: [Tweet], for trend: Trend) {
        self.tweetCache?.setObject(tweets, forKey: trend.query! as NSCopying)
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trends?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: trendCellID) as! TrendCell
        cell.trend = self.trends?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}


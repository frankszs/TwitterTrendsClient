//
//  TweetsController.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 26/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

class TweetsController: UIViewController {
    
    let tweetCellID = "tweetCell"
    
    @IBOutlet var tableView : UITableView!
    var refreshControl : UIRefreshControl!
    
    var trend : Trend?
    var tweets : [Tweet]?
    
    var cacheDelegate : TweetCacheProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = self.refreshControl
        self.tableView.backgroundColor = UIColor.white
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        self.reloadData()
    }
    
    func reloadData(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Client.sharedInstance.getSearchTweets(searchText: (trend?.query)!, amount: 50, success: { (tweets) in
            
            self.tweets = tweets
            
            self.cacheDelegate?.updateCache(tweets: tweets, for: self.trend!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            }) { (error) in
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
        }
    }
    
}

extension TweetsController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetCellID) as! TweetCell
        cell.tweet = self.tweets?[indexPath.row]
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
////        return
//    }
}

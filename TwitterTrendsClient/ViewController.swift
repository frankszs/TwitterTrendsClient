//
//  ViewController.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 17/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit
import CoreData

protocol TweetCacheProtocol{
    
    func updateCache(tweets : [Tweet], for trend : Trend)
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    let trendCellID = "trendCell"
    let segmentedHeaderViewID = "SegmentedHeaderView"
    
    @IBOutlet weak var tableView : UITableView!
    var segmentView : SegmentedView?
    var refreshControl : UIRefreshControl!

    var latestTrends : [Trend]?
    var savedTrends : [SavedTrend]?
    
    var showLatest : Bool{
        return !showSaved
        }
    var showSaved : Bool{
        return segmentView?.selectedIndex == 1
    }
    
    var tweetCache: NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        do{
            let savedTrends : [SavedTrend]? = try context.fetch(SavedTrend.fetchRequest())
            self.savedTrends = savedTrends
        } catch { print("ERROR GETTING TRENDS")}
        
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = self.refreshControl
        tableView.backgroundColor = UIColor.white
        
        self.tableView.register(UINib.init(nibName: "TrendCell", bundle: nil), forCellReuseIdentifier: trendCellID)
        
        self.tableView.register(UINib.init(nibName: "SegmentedHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: segmentedHeaderViewID)
        
        self.reloadData()
        
    }
    
    func reloadData(){
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        do{
            let savedTrends : [SavedTrend]? = try context.fetch(SavedTrend.fetchRequest())
            self.savedTrends = savedTrends
        } catch { print("ERROR GETTING TRENDS")}
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Client.sharedInstance.getTopTrends(WOEID: "23424977", amount: 30, success: {trends in
            
            self.latestTrends = trends

            //Reconstruct cache.
            self.tweetCache = NSMutableDictionary()
            for trend in self.latestTrends!{
                Client.sharedInstance.getSearchTweets(searchText: trend.query!, amount: 20, success: {tweets in self.tweetCache?.setObject(tweets, forKey: trend.name! as NSCopying)}, failure: {error in})
            }
            if self.savedTrends != nil{
                for savedTrend in self.savedTrends!{
                    let savedTrend = Trend.init(savedTrend: savedTrend)
                    Client.sharedInstance.getSearchTweets(searchText: savedTrend.query!, amount: 20, success: {tweets in self.tweetCache?.setObject(tweets, forKey: savedTrend.name! as NSCopying)}, failure: {error in})
                }
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
        
        if segue.identifier == "A"{
            //print("prepareForSegue")
            if let trend = sender as? Trend{
                let destinationController = segue.destination as! TweetsController
                destinationController.trend = trend
                let tweets = self.tweetCache?.object(forKey: trend.name!) as! [Tweet]?
                destinationController.tweets = tweets
                destinationController.cacheDelegate = self
                
            }
        }
    }
    
    @IBAction func segmentedViewValueDidChange(_ segmnetedView : SegmentedView){
        
        self.tableView.reloadData()
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  (self.showLatest ? self.latestTrends?.count : self.savedTrends?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: trendCellID) as! TrendCell
        let trend : Trend? =  self.showLatest ? self.latestTrends?[indexPath.row] : Trend.init(savedTrend:self.savedTrends?[indexPath.row])
        cell.trend = trend
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: segmentedHeaderViewID)
        if let headerView = view as? SegmentedHeaderView{
            
            headerView.segmentedView.setSetments(["Latest", "Saved"])
            self.segmentView = headerView.segmentedView
            self.segmentView?.addTarget(self, action: #selector(segmentedViewValueDidChange(_:)), for: .valueChanged)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let trend : Trend? = self.showLatest ? self.latestTrends?[indexPath.row] : Trend.init(savedTrend:self.savedTrends?[indexPath.row])
        self.performSegue(withIdentifier: "A", sender: trend)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if self.showSaved{
            return .delete
        }
        
        else{
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard self.showSaved else { return }
        
        if editingStyle == .delete{
            let savedTrend = self.savedTrends![indexPath.row]
            self.savedTrends?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            context.delete(savedTrend)
            appDelegate.saveContext()
        }
    }
    
}

extension ViewController : TweetCacheProtocol{
    
    func updateCache(tweets: [Tweet], for trend: Trend) {
        self.tweetCache?.setObject(tweets, forKey: trend.name! as NSCopying)
    }
}


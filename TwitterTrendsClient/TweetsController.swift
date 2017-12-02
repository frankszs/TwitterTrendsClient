//
//  TweetsController.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 26/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit
import CoreData

class TweetsController: UIViewController {
    
    let tweetCellID = "tweetCell"
    
    @IBOutlet var tableView : UITableView!
    var refreshControl : UIRefreshControl!
    
    var trend : Trend?
    var tweets : [Tweet]?
    
    var cacheDelegate : TweetCacheProtocol?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context : NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.context = appDelegate.persistentContainer.viewContext
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = self.refreshControl
        self.tableView.backgroundColor = UIColor.white
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        self.tableView.register(UINib.init(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: tweetCellID)
        
        self.navigationItem.title = self.trend?.name
        
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
    
    func getImageWithLink(linkString : String, completion : @escaping (UIImage?) -> Void){
        
        let client = Client.sharedInstance
        
        //Check if cache has image.
        if let image = client.imageCache.object(forKey: linkString as NSString) as? UIImage{
            completion(image)
        }
        //Need to download image.
        else{
            let url = URL.init(string: linkString);
            guard url != nil else { return }
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
              
                if let nserror = error {
                    print("Error downloading image with error: \(nserror.localizedDescription)")
                    return
                }
                
                //Image was downloaded.
                let image = UIImage(data: data!)
                client.imageCache.setObject(image!, forKey: linkString as NSString)
                
                DispatchQueue.main.async(execute: { completion(image) })
                
            }).resume()
        }
    }
    
    @IBAction func saveButtonDidTap(){
        
        //Create savedTrend
        guard let context = self.context else { return }
        let savedTrend = SavedTrend(context: context)
        savedTrend.name = self.trend?.name
        savedTrend.query = self.trend?.query
        self.appDelegate.saveContext()
        print("SAVED")
    }
    
}

extension TweetsController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tweet = self.tweets?[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetCellID) as! TweetCell
        cell.tweet = tweet
        
        self.getImageWithLink(linkString: (tweet?.user?.profileImageLink)!) { (image) in
            cell.userProfileImageView.image = image
        }
        
        return cell
    }
}

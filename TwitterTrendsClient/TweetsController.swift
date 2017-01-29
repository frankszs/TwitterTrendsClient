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
              
                if error != nil{
                    print("Error downloading image with error: \(error)")
                    return
                }
                
                //Image was downloaded.
                let image = UIImage(data: data!)
                client.imageCache.setObject(image!, forKey: linkString as NSString)
                
                DispatchQueue.main.async(execute: { completion(image) })
                
            }).resume()
        }
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

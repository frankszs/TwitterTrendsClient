//
//  TweetsController.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 26/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit
import CoreData

protocol TweetsControllerDelegate : class {
    
    func didUpdateSavedTrends()
}

class TweetsController: UIViewController {
    
    //MARK: - Properties
    
    let tweetCellID = "tweetCell"
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var saveButton : UIBarButtonItem!
    var refreshControl : UIRefreshControl!
    
    weak var delegate : TweetsControllerDelegate?
    
    var trend : Trend?
    var tweets : [Tweet]?
    
    var cacheDelegate : TweetCacheProtocol?
    
    //MARK: - ViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = self.refreshControl
        self.tableView.backgroundColor = UIColor.white
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        self.tableView.register(UINib.init(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: tweetCellID)
        self.tableView.contentInsetAdjustmentBehavior = .never
        
        self.navigationItem.title = self.trend?.name
        
        print("fdf")
        if Storage.trendIsSaved(trend: trend!){
            print("Vd")
            self.saveButton.title = "Remove"
        }
        
        self.reloadData()
    }
    
    //MARK: - Update Data Methods
    
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
    
    //MARK: - IBAction Methods
    
    @IBAction func saveButtonDidTap(){
        
        if Storage.trendIsSaved(trend: self.trend!){
            
            //Delete trend.
            _ = Storage.deleteSavedTrend(using: self.trend!)
            Storage.saveContext()
            self.saveButton.title = "Save"
        }
        
        else{
            //Create savedTrend.
            let context = Storage.context
            let savedTrend = SavedTrend(context: context)
            savedTrend.name = self.trend?.name
            savedTrend.query = self.trend?.query
            Storage.saveContext()
            
            self.saveButton.title = "Remove"
        }
        
        self.delegate?.didUpdateSavedTrends()
    }
    
}

    //MARK: - UITableView Methods

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

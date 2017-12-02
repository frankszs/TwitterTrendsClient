//
//  SearchController.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 30/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

class SearchController: UIViewController, UISearchControllerDelegate {
    
    @IBOutlet var tableView : UITableView!
    var searchController : UISearchController?
    
       override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController = UISearchController.init(searchResultsController: nil)
        self.searchController?.searchResultsUpdater = self
        
        self.navigationItem.titleView = self.searchController?.searchBar
        self.searchController?.hidesNavigationBarDuringPresentation = false
        self.searchController?.dimsBackgroundDuringPresentation = true
        self.definesPresentationContext = true
    }

}

extension SearchController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

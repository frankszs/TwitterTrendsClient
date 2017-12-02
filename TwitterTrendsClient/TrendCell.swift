//
//  TrendCell.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 26/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

class TrendCell: UITableViewCell {
    
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var detailsLabel : UILabel!
    
    var trend : Trend? {
        willSet{
            self.nameLabel.text = newValue?.name
            
            if let tweetVolume = newValue?.tweetVolume{
                
                self.detailsLabel.isHidden = false
                self.detailsLabel.text = "\(tweetVolume/1000)K tweets"
            }
            else{
                self.detailsLabel.isHidden = true
            }
        }
    }
    var color: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.color = self.nameLabel.textColor
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        if highlighted{
            self.backgroundColor = self.color
            self.nameLabel.textColor = UIColor.white
            self.detailsLabel.textColor = UIColor.white
        }
        else{
            self.backgroundColor = UIColor.white
            self.nameLabel.textColor = self.color
            self.detailsLabel.textColor = UIColor.lightGray
        }
        
    }
    
}

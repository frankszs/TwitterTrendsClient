//
//  TweetCell.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 26/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var retweetLabel : UILabel?
    @IBOutlet var retweetImageView : UIImageView?

    
    var tweet : Tweet? {
        willSet{
            self.nameLabel.text = newValue?.text
            self.retweetLabel?.text = "\(newValue!.retweetCount!)"
        }
    }

    var color: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.color = self.nameLabel.textColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        if highlighted{
            self.backgroundColor = self.color
            self.nameLabel.textColor = UIColor.white
            self.retweetLabel?.textColor = UIColor.white
        }
        else{
            self.backgroundColor = UIColor.white
            self.nameLabel.textColor = self.color
            self.retweetLabel?.textColor = UIColor.lightGray
        }
        
    }

}

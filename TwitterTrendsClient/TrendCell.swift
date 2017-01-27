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
    
    var trend : Trend? {
        willSet{
            self.nameLabel.text = newValue?.name
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
        }
        else{
            self.backgroundColor = UIColor.white
            self.nameLabel.textColor = self.color
        }
        
    }
    
}

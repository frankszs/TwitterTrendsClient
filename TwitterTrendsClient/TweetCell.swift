//
//  TweetCell.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 26/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var tweetLabel : UILabel!
    @IBOutlet weak var userNameLabel : UILabel!
    @IBOutlet weak var userProfileImageView : UIImageView!
    @IBOutlet weak var userProfileShadowView : UIView!

    
    var tweet : Tweet? {
        willSet{
            self.tweetLabel.text = newValue?.text
            self.userNameLabel?.text = newValue?.user?.screenName
        }
    }
    

    var color: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.color = self.tweetLabel.textColor
        self.selectionStyle = UITableViewCellSelectionStyle.none
    
        self.userProfileShadowView.clipsToBounds = false
        self.userProfileShadowView.layer.shadowColor = UIColor.black.cgColor
        self.userProfileShadowView.layer.shadowOpacity = 0.15
        self.userProfileShadowView.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.userProfileShadowView.layer.shadowRadius = 3
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        if highlighted{
            self.backgroundColor = self.color
            self.tweetLabel.textColor = UIColor.white
            self.userNameLabel?.textColor = UIColor.white
        }
        else{
            self.backgroundColor = UIColor.white
            self.tweetLabel.textColor = self.color
            self.userNameLabel?.textColor = UIColor.darkGray
        }
        
    }

}

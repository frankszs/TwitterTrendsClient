//
//  ProfileImageView.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 28/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {
    
    override var frame: CGRect{
        willSet{
            let width = newValue.width
            self.layer.cornerRadius = width/2.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
    }
}

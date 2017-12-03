//
//  ProfileImageView.swift
//  TwitterTrendsClient
//
//  Created by f0dsterz on 28/01/17.
//  Copyright © 2017 frankszs. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.lightGray
        self.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        let width = self.bounds.width
        self.layer.cornerRadius = width/2.0
    }
}

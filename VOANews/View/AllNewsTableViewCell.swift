//
//  AllNewsTableViewCell.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/30.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit

class AllNewsTableViewCell: UITableViewCell {
    @IBOutlet var newsIconImageView: UIImageView! {
        didSet {
            newsIconImageView.layer.cornerRadius = newsIconImageView.bounds.width / 2
            newsIconImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet var newsNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

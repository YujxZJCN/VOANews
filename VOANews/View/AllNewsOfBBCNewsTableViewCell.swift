//
//  AllNewsOfBBCNewsTableViewCell.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/30.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit

class AllNewsOfBBCNewsTableViewCell: UITableViewCell {
    @IBOutlet var BBCNewsIconImageView: UIImageView! {
        didSet {
            BBCNewsIconImageView.layer.cornerRadius = BBCNewsIconImageView.bounds.width / 2
            BBCNewsIconImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet var NewsNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

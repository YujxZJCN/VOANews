//
//  AllNewsOfCNNNewsTableViewCell.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/30.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit

class AllNewsOfCNNNewsTableViewCell: UITableViewCell {
    @IBOutlet var CNNNewxIconImageView: UIImageView! {
        didSet {
            CNNNewxIconImageView.layer.cornerRadius = CNNNewxIconImageView.bounds.width / 2
            CNNNewxIconImageView.layer.masksToBounds = true
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
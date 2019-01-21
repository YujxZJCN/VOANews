//
//  BBCNewsTableViewCell.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/21.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit

class BBCNewsTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var heartImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  VOANewsDetailTableViewCell.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/20.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit

class VOANewsDetailTableViewCell: UITableViewCell {

    @IBOutlet var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

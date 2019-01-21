//
//  VOANews.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/19.
//  Copyright © 2019 Albert. All rights reserved.
//

import Foundation

class News {
    var name: String
    var url: String
    var isLiked: Bool
    
    init(name: String, url: String, isLiked: Bool) {
        self.name = name
        self.url = url
        self.isLiked = isLiked
    }
}

//
//  ManageFavorateNews+CoreDataClass.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/24.
//  Copyright © 2019 Albert. All rights reserved.
//
//

import Foundation
import CoreData


public class ManageFavorateNews: NSManagedObject {
    func initialize(with item: News) {
        newsName = item.name
        newsURL = item.url
        isLiked = item.isLiked
    }
    
    func export() -> News {
        let news = News(name: newsName!, url: newsURL!, isLiked: isLiked)
        return news
    }
}

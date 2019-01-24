//
//  ManageFavorateNews+CoreDataProperties.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/24.
//  Copyright © 2019 Albert. All rights reserved.
//
//

import Foundation
import CoreData


extension ManageFavorateNews {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManageFavorateNews> {
        return NSFetchRequest<ManageFavorateNews>(entityName: "ManageFavorateNews")
    }

    @NSManaged public var isLiked: Bool
    @NSManaged public var newsName: String?
    @NSManaged public var newsURL: String?

}

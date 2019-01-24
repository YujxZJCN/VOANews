//
//  DataManager.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/24.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit
import CoreData

class DataManager {
    
    static let shared = DataManager()
    
    private var context: NSManagedObjectContext = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return context
    }()
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            fatalError("Error occurred when saving a context.")
        }
    }
    
    func createFavorateNews(item: News) {
        let entity = NSEntityDescription.entity(forEntityName: "ManageFavorateNews", in: context)
        let newFavorateNews = ManageFavorateNews(entity: entity!, insertInto: context)
        newFavorateNews.initialize(with: item)
        saveContext()
    }
    
    func removeFavorateNews(item: News) {
        removeFavorateNews(name: item.name)
    }
    
    func getAllFavorateNews() -> [News] {
        let fetchRequest: NSFetchRequest = ManageFavorateNews.fetchRequest()
        let manageItems = (try! context.fetch(fetchRequest)) as [ManageFavorateNews]
        var favorateNews: [News] = []
        for item in manageItems {
            favorateNews.append(item.export())
        }
        return favorateNews
    }
    
    private func removeFavorateNews(name: String) {
        let fetchRequest: NSFetchRequest = ManageFavorateNews.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "newsName == \"\(name)\"")
        let results = try! context.fetch(fetchRequest)
        
        // There should be only 1 result, thus the for loop should iterate only once
        for item in results {
            context.delete(item)
        }
        saveContext()
    }
    
}

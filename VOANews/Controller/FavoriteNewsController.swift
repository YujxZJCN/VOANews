//
//  FavoriteNewsController.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/24.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit

class FavorateNewsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var favorateNewsTableView: UITableView!
    var VOANews = [News]()
    var BBCNews = [News]()
    var CNNNews = [News]()
    var AsItIs = [News]()
    //    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        if VOANews.count > 0 { count += 1 }
        //        if BBCNews.count > 0 { count += 1 }
        //        if CNNNews.count > 0 { count += 1 }
        //        if otherNews.count > 0 { count += 1 }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        VOANews.removeAll()
        BBCNews.removeAll()
        CNNNews.removeAll()
        AsItIs.removeAll()
        for news in favoriteNews {
            if news.name.contains("VOA") {
                VOANews.append(news)
            }else if news.name.contains("BBC") {
                BBCNews.append(news)
            }else if news.name.contains("CNN") {
                CNNNews.append(news)
            }else {
                AsItIs.append(news)
            }
        }
        favorateNewsTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return VOANews.count
        case 1:
            return BBCNews.count
        case 2:
            return CNNNews.count
        case 3:
            return AsItIs.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "VOA News"
        case 1:
            return "BBC News"
        case 2:
            return "CNN News"
        case 3:
            return "As It Is"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "FavorateNewsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! FavorateNewsTableViewCell
        switch indexPath.section {
        case 0:
            cell.nameLabel.text = VOANews[indexPath.row].name
            cell.dateLabel.text = transformToDate(url: VOANews[indexPath.row].url, number: 6)
        case 1:
            cell.nameLabel.text = BBCNews[indexPath.row].name
            var number = 5
            if BBCNews[indexPath.row].url.contains("huanqiu") {
                number = 6
            }
            cell.dateLabel.text = transformToDate(url: BBCNews[indexPath.row].url, number: number)
        case 2:
            cell.nameLabel.text = CNNNews[indexPath.row].name
            cell.dateLabel.text = transformToDate(url: CNNNews[indexPath.row].url, number: 5)
        case 3:
            cell.nameLabel.text = AsItIs[indexPath.row].name
            cell.dateLabel.text = transformToDate(url: AsItIs[indexPath.row].url, number: 6)
        default:
            cell.nameLabel.text = ""
            cell.dateLabel.text = ""
        }
        
        return cell
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let identifier = "FavorateNewsCell"
        let hsCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FavorateNewsTableViewCell
        var tempCell: FavorateNewsTableViewCell
        hsCell != nil ? (tempCell = hsCell!) : (tempCell = FavorateNewsTableViewCell())
        switch indexPath.section {
        case 0:
            tempCell.nameLabel.text = VOANews[indexPath.row].name
            tempCell.dateLabel.text = transformToDate(url: VOANews[indexPath.row].url, number: 6)
        case 1:
            tempCell.nameLabel.text = BBCNews[indexPath.row].name
            var number = 5
            if BBCNews[indexPath.row].url.contains("huanqiu") {
                number = 6
            }
            tempCell.dateLabel.text = transformToDate(url: BBCNews[indexPath.row].url, number: number)
        case 2:
            tempCell.nameLabel.text = CNNNews[indexPath.row].name
            tempCell.dateLabel.text = transformToDate(url: CNNNews[indexPath.row].url, number: 5)
        case 3:
            tempCell.nameLabel.text = AsItIs[indexPath.row].name
            tempCell.dateLabel.text = transformToDate(url: AsItIs[indexPath.row].url, number: 6)
        default:
            tempCell.nameLabel.text = ""
            tempCell.dateLabel.text = ""
        }
        
        tempCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
        tempCell.layoutIfNeeded()
        return tempCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "") { (action, sourceView, completionHandler) in
            
            // Delete the row from the data source
            //            for news in favoriteNews {
            //                if news.name ==
            //            }
            //            DataManager.shared.removeFavorateNews(item: <#T##News#>)
            //            self.bikeInfos.remove(at: indexPath.row)
            //            self.tableView.deleteRows(at: [indexPath], with: .fade)
            var newsName = ""
            switch indexPath.section {
            case 0:
                newsName = self.VOANews[indexPath.row].name
                self.VOANews.remove(at: indexPath.row)
            case 1:
                newsName = self.BBCNews[indexPath.row].name
                self.BBCNews.remove(at: indexPath.row)
            case 2:
                newsName = self.CNNNews[indexPath.row].name
                self.CNNNews.remove(at: indexPath.row)
            case 3:
                newsName = self.AsItIs[indexPath.row].name
                self.AsItIs.remove(at: indexPath.row)
            default:
                newsName = ""
            }
            var numberOfFavorateNews = -1
            for index in 0 ..< favoriteNews.count {
                if favoriteNews[index].name == newsName {
                    numberOfFavorateNews = index
                }
            }
            DataManager.shared.removeFavorateNews(item: favoriteNews[numberOfFavorateNews])
            favoriteNews.remove(at: numberOfFavorateNews)
            self.favorateNewsTableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        
        // Set the icon and background color for the actions
        deleteAction.backgroundColor = UIColor(red: 231, green: 76, blue: 60)
        deleteAction.image = UIImage(named: "delete")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeConfiguration
    }
    
    func transformToDate(url: String, number: Int) -> String {
        let components = url.components(separatedBy: "/")
        var date = components[number]
        if !date.contains("-") {
            let year = date[date.startIndex ... date.index(date.startIndex, offsetBy: 3)]
            let month = date[date.index(date.startIndex, offsetBy: 4) ... date.index(date.startIndex, offsetBy: 5)]
            let day = date[date.index(date.startIndex, offsetBy: 6) ... date.index(date.startIndex, offsetBy: 7)]
            date = String(year + "-" + month + "-" + day)
        }
        return date
    }
    
}

extension FavorateNewsController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let allFavorateNews = VOANews + BBCNews + CNNNews + AsItIs
        var indexNumber = 0
        if let indexPath = favorateNewsTableView.indexPathForSelectedRow {
            switch indexPath.section {
            case 0:
                indexNumber = indexPath.row
            case 1:
                indexNumber = indexPath.row + VOANews.count
            case 2:
                indexNumber = indexPath.row + VOANews.count + BBCNews.count
            case 3:
                indexNumber = indexPath.row + VOANews.count + BBCNews.count + CNNNews.count
            default:
                indexNumber = 0
            }
        }
        
        if segue.identifier == "showFavorateNewsDetail" {
            let destinationController = segue.destination as! NewsDetailViewController
            destinationController.newsItems = allFavorateNews
            destinationController.indexOfnews = indexNumber
            destinationController.newsItemName = allFavorateNews[indexNumber].name
            destinationController.newsItemURL = allFavorateNews[indexNumber].url
            destinationController.newsType = "FavorateNews"
        }
    }
}

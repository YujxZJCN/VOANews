//
//  VOANewsTableViewController.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/19.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import NVActivityIndicatorView

class VOANewsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var VOANewsTableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var refreshButton: UIButton!
    
    var url = "http://www.hxen.com/englishlistening/voaenglish/voaspecialenglish/index"
    
    @IBAction func showMode(_ sender: UISegmentedControl) {
        page = 2
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            url = "http://www.hxen.com/englishlistening/voaenglish/voaspecialenglish/index"
            VOANewsList = [News]()
            activityIndicator.startAnimating()
            loadData()
        case 1:
            url = "http://www.hxen.com/englishlistening/voaenglish/voastandardenglish/index"
            VOANewsList = [News]()
            activityIndicator.startAnimating()
            loadData()
        default: break
        }
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        VOANewsList.removeAll()
        activityIndicator.startAnimating()
        loadDataTimes = 0
        page = 2
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    
    var VOANewsList = [News]() {
        didSet {
            self.activityIndicator.stopAnimating()
            VOANewsTableView.reloadData()
            if timer.isValid {
                timer.invalidate()
            }
        }
    }
    
    var activityIndicator: NVActivityIndicatorView!
    var timer = Timer()
    var loadDataTimes = 0 {
        didSet {
            if loadDataTimes > 20 {
                self.activityIndicator.stopAnimating()
                timer.invalidate()
                
                let alertController = UIAlertController(title: "请检查网络连接", message: "", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                }
                
                loadDataTimes = 0
            }
        }
    }
    var page = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        favoriteNews = DataManager.shared.getAllFavorateNews()
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .ballRotateChase, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.lightGray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        VOANewsTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        timer.fire()
    }
    
    @objc fileprivate func loadData() {
        Alamofire.request((url + ".html"), method: .get).responseData { response in
            if let error = response.error {
                if error.localizedDescription == "The Internet connection appears to be offline." {
                    print("未连接网络")
                }
            }
            let enc: String.Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632))
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: enc) {
                for content in doc.css(".fz18") {
                    if let innerHtml = content.innerHTML {
                        let components = innerHtml.components(separatedBy: "\"")
                        let VOANewsItem = News.init(name: components[1], url: "http://www.hxen.com" + components[3], isLiked: false)
                        self.VOANewsList.append(VOANewsItem)
                    }
                }
            }
            
            for index in 0 ..< self.VOANewsList.count {
                if self.VOANewsList[index].name.contains("¡¯") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "¡¯", with: "\'")
                }
                if self.VOANewsList[index].name.contains("VOA慢速英语:") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "VOA慢速英语:", with: "VOA慢速英语：")
                }
                if self.VOANewsList[index].name.contains("VOA常速英语:") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "VOA常速英语:", with: "VOA常速英语：")
                }
                for news in favoriteNews {
                    if news.name == self.VOANewsList[index].name {
                        self.VOANewsList[index].isLiked = true
                    }
                }
            }
        }
        loadDataTimes += 1
    }
    
    func loadMore(url: String) {
        Alamofire.request((url + ".html"), method: .get).responseData { response in
            if let error = response.error {
                if error.localizedDescription == "The Internet connection appears to be offline." {
                    print("未连接网络")
                }
            }
            let enc: String.Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632))
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: enc) {
                for content in doc.css(".fz18") {
                    if let innerHtml = content.innerHTML {
                        let components = innerHtml.components(separatedBy: "\"")
                        let VOANewsItem = News.init(name: components[1], url: "http://www.hxen.com" + components[3], isLiked: false)
                        self.VOANewsList.append(VOANewsItem)
                    }
                }
                self.page += 1
            }
            
            for index in 0 ..< self.VOANewsList.count {
                if self.VOANewsList[index].name.contains("¡¯") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "¡¯", with: "\'")
                }
                if self.VOANewsList[index].name.contains("VOA慢速英语:") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "VOA慢速英语:", with: "VOA慢速英语：")
                }
                if self.VOANewsList[index].name.contains("VOA常速英语:") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "VOA常速英语:", with: "VOA常速英语：")
                }
                for news in favoriteNews {
                    if news.name == self.VOANewsList[index].name {
                        self.VOANewsList[index].isLiked = true
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VOANewsList.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 88
//    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let identifier = "VOANewsCell"
        let hsCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? VOANewsTableViewCell
        var tempCell: VOANewsTableViewCell
        hsCell != nil ? (tempCell = hsCell!) : (tempCell = VOANewsTableViewCell())
        tempCell.nameLabel.text = VOANewsList[indexPath.row].name
        
        let components = VOANewsList[indexPath.row].url.components(separatedBy: "/")
        
        var date = components[6]
        if !date.contains("-") {
            let year = date[date.startIndex ... date.index(date.startIndex, offsetBy: 3)]
            let month = date[date.index(date.startIndex, offsetBy: 4) ... date.index(date.startIndex, offsetBy: 5)]
            let day = date[date.index(date.startIndex, offsetBy: 6) ... date.index(date.startIndex, offsetBy: 7)]
            date = String(year + "-" + month + "-" + day)
        }
        tempCell.dateLabel.text = date
        tempCell.heartImageView.isHidden = VOANewsList[indexPath.row].isLiked ? false : true
        
        tempCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
        tempCell.layoutIfNeeded()
        return tempCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "VOANewsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! VOANewsTableViewCell
        
        // Configure the cell...
        cell.nameLabel.text = VOANewsList[indexPath.row].name
        
        let components = VOANewsList[indexPath.row].url.components(separatedBy: "/")
        var date = components[6]
        if !date.contains("-") {
            let year = date[date.startIndex ... date.index(date.startIndex, offsetBy: 3)]
            let month = date[date.index(date.startIndex, offsetBy: 4) ... date.index(date.startIndex, offsetBy: 5)]
            let day = date[date.index(date.startIndex, offsetBy: 6) ... date.index(date.startIndex, offsetBy: 7)]
            date = String(year + "-" + month + "-" + day)
        }
        cell.dateLabel.text = date
        VOANewsList[indexPath.row].isLiked = false
        for news in favoriteNews {
            if news.name == VOANewsList[indexPath.row].name {
                VOANewsList[indexPath.row].isLiked = true
            }
        }
        cell.heartImageView.isHidden = VOANewsList[indexPath.row].isLiked ? false : true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = VOANewsList.count - 1
        if indexPath.row == lastElement {
            activityIndicator.startAnimating()
            // handle your logic here to get more items, add it to dataSource and reload tableview
            loadMore(url: url + "_\(page)")
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let checkInAction = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath) as! VOANewsTableViewCell
            self.VOANewsList[indexPath.row].isLiked = (self.VOANewsList[indexPath.row].isLiked) ? false : true
            cell.heartImageView.isHidden = self.VOANewsList[indexPath.row].isLiked ? false : true
            if self.VOANewsList[indexPath.row].isLiked {
                favoriteNews.append(self.VOANewsList[indexPath.row])
                DataManager.shared.createFavorateNews(item: self.VOANewsList[indexPath.row])
            } else {
                var numberOfFavorateNewsToBeDeleted = 0
                for index in 0 ..< favoriteNews.count {
                    if favoriteNews[index].name == self.VOANewsList[indexPath.row].name {
                        numberOfFavorateNewsToBeDeleted = index
                    }
                }
                favoriteNews.remove(at: numberOfFavorateNewsToBeDeleted)
                DataManager.shared.removeFavorateNews(item: self.VOANewsList[indexPath.row])
            }
            completionHandler(true)
        }
        
        let checkInIcon = VOANewsList[indexPath.row].isLiked ? "undo" : "tick"
        checkInAction.backgroundColor = UIColor(red: 38, green: 162, blue: 78)
        checkInAction.image = UIImage(named: checkInIcon)
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [checkInAction])
        
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        return UISwipeActionsConfiguration.init()
    }
    
}

extension VOANewsController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVOANewsDetail" {
            if let indexPath = VOANewsTableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! NewsDetailViewController
                destinationController.newsItems = VOANewsList
                destinationController.indexOfnews = indexPath.row
                destinationController.newsItemName = VOANewsList[indexPath.row].name
                destinationController.newsItemURL = VOANewsList[indexPath.row].url
                destinationController.newsType = "VOANews"
            }
        }
    }
}

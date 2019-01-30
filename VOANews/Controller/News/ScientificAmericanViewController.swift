//
//  ScientificAmericanViewController.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/30.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import Kanna
import AVFoundation
import MediaPlayer

class ScientificAmericanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var ScientificAmericanTableView: UITableView!
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func refresh(_ sender: UIButton) {
        ScientificAmericanList.removeAll()
        activityIndicator.startAnimating()
        loadDataTimes = 0
        page = 2
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    
    var url = "http://www.hxen.com/englishlistening/other/scientificamerican/index"
    
    var ScientificAmericanList = [News]() {
        didSet {
            self.activityIndicator.stopAnimating()
            ScientificAmericanTableView.reloadData()
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

        // Do any additional setup after loading the view.
        ScientificAmericanTableView.delegate = self
        ScientificAmericanTableView.dataSource = self
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
        ScientificAmericanTableView.reloadData()
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
                        var components = innerHtml.components(separatedBy: "\'")
                        if components.count != 1 {
                        }else {
                            components = innerHtml.components(separatedBy: "\"")
                         }
                        components = innerHtml.components(separatedBy: "\"")
                        let ScientificAmericanItem = News.init(name: content.content ?? "", url: "http://www.hxen.com" + components[3], isLiked: false)
                        self.ScientificAmericanList.append(ScientificAmericanItem)
                    }
                }
            }
            
            for index in 0 ..< self.ScientificAmericanList.count {
                if self.ScientificAmericanList[index].name.contains("¡¯") {
                    self.ScientificAmericanList[index].name = self.ScientificAmericanList[index].name.replacingOccurrences(of: "¡¯", with: "\'")
                }
                if self.ScientificAmericanList[index].name.contains("60秒:") {
                    self.ScientificAmericanList[index].name = self.ScientificAmericanList[index].name.replacingOccurrences(of: "60秒:", with: "60秒：")
                }
                for news in favoriteNews {
                    if news.name == self.ScientificAmericanList[index].name {
                        self.ScientificAmericanList[index].isLiked = true
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
                        var components = innerHtml.components(separatedBy: "\'")
                        if components.count != 1 {
                        }else {
                            components = innerHtml.components(separatedBy: "\"")
                        }
                        components = innerHtml.components(separatedBy: "\"")
                        let ScientificAmericanItem = News.init(name: content.content ?? "", url: "http://www.hxen.com" + components[3], isLiked: false)
                        self.ScientificAmericanList.append(ScientificAmericanItem)
                    }
                }
                self.page += 1
            }
            
            for index in 0 ..< self.ScientificAmericanList.count {
                if self.ScientificAmericanList[index].name.contains("¡¯") {
                    self.ScientificAmericanList[index].name = self.ScientificAmericanList[index].name.replacingOccurrences(of: "¡¯", with: "\'")
                }
                if self.ScientificAmericanList[index].name.contains("60秒:") {
                    self.ScientificAmericanList[index].name = self.ScientificAmericanList[index].name.replacingOccurrences(of: "60秒:", with: "60秒：")
                }
                for news in favoriteNews {
                    if news.name == self.ScientificAmericanList[index].name {
                        self.ScientificAmericanList[index].isLiked = true
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
        return ScientificAmericanList.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let identifier = "ScientificAmericanCell"
        let hsCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ScientificAmericanTableViewCell
        var tempCell: ScientificAmericanTableViewCell
        hsCell != nil ? (tempCell = hsCell!) : (tempCell = ScientificAmericanTableViewCell())
        tempCell.nameLabel.text = ScientificAmericanList[indexPath.row].name
        
        let components = ScientificAmericanList[indexPath.row].url.components(separatedBy: "/")
        var date = components[5]
        if !date.contains("-") {
            let year = date[date.startIndex ... date.index(date.startIndex, offsetBy: 3)]
            let month = date[date.index(date.startIndex, offsetBy: 4) ... date.index(date.startIndex, offsetBy: 5)]
            let day = date[date.index(date.startIndex, offsetBy: 6) ... date.index(date.startIndex, offsetBy: 7)]
            date = String(year + "-" + month + "-" + day)
        }
        
        tempCell.dateLabel.text = date
        tempCell.heartImageView.isHidden = ScientificAmericanList[indexPath.row].isLiked ? false : true
        
        tempCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
        tempCell.layoutIfNeeded()
        return tempCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ScientificAmericanCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ScientificAmericanTableViewCell
        
        // Configure the cell...
        cell.nameLabel.text = ScientificAmericanList[indexPath.row].name
        
        let components = ScientificAmericanList[indexPath.row].url.components(separatedBy: "/")
        var date = components[6]
        if !date.contains("-") {
            let year = date[date.startIndex ... date.index(date.startIndex, offsetBy: 3)]
            let month = date[date.index(date.startIndex, offsetBy: 4) ... date.index(date.startIndex, offsetBy: 5)]
            let day = date[date.index(date.startIndex, offsetBy: 6) ... date.index(date.startIndex, offsetBy: 7)]
            date = String(year + "-" + month + "-" + day)
        }
        cell.dateLabel.text = date
        ScientificAmericanList[indexPath.row].isLiked = false
        for news in favoriteNews {
            if news.name == ScientificAmericanList[indexPath.row].name {
                ScientificAmericanList[indexPath.row].isLiked = true
            }
        }
        cell.heartImageView.isHidden = ScientificAmericanList[indexPath.row].isLiked ? false : true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = ScientificAmericanList.count - 1
        if indexPath.row == lastElement {
            activityIndicator.startAnimating()
            // handle your logic here to get more items, add it to dataSource and reload tableview
            loadMore(url: url + "_\(page)")
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let checkInAction = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath) as! ScientificAmericanTableViewCell
            self.ScientificAmericanList[indexPath.row].isLiked = (self.ScientificAmericanList[indexPath.row].isLiked) ? false : true
            cell.heartImageView.isHidden = self.ScientificAmericanList[indexPath.row].isLiked ? false : true
            if self.ScientificAmericanList[indexPath.row].isLiked {
                favoriteNews.append(self.ScientificAmericanList[indexPath.row])
                DataManager.shared.createFavorateNews(item: self.ScientificAmericanList[indexPath.row])
            } else {
                var numberOfFavorateNewsToBeDeleted = 0
                for index in 0 ..< favoriteNews.count {
                    if favoriteNews[index].name == self.ScientificAmericanList[indexPath.row].name {
                        numberOfFavorateNewsToBeDeleted = index
                    }
                }
                favoriteNews.remove(at: numberOfFavorateNewsToBeDeleted)
                DataManager.shared.removeFavorateNews(item: self.ScientificAmericanList[indexPath.row])
            }
            completionHandler(true)
        }
        
        let checkInIcon = ScientificAmericanList[indexPath.row].isLiked ? "undo" : "tick"
        checkInAction.backgroundColor = UIColor(red: 38, green: 162, blue: 78)
        checkInAction.image = UIImage(named: checkInIcon)
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [checkInAction])
        
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        return UISwipeActionsConfiguration.init()
    }
}

extension ScientificAmericanViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScientificAmericanDetail" {
            if let indexPath = ScientificAmericanTableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! NewsDetailViewController
                destinationController.newsItems = ScientificAmericanList
                destinationController.indexOfnews = indexPath.row
                destinationController.newsItemName = ScientificAmericanList[indexPath.row].name
                destinationController.newsItemURL = ScientificAmericanList[indexPath.row].url
                destinationController.newsType = "Scientific American"
            }
        }
    }
}

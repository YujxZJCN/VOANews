//
//  CNNNewsViewController.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/21.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import Kanna
import AVFoundation
import MediaPlayer

class CNNNewsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var CNNNewsTableView: UITableView!
    
    @IBAction func refresh(_ sender: UIButton) {
        CNNNewsList.removeAll()
        activityIndicator.startAnimating()
        loadDataTimes = 0
        page = 2
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    
    var url = "http://www.hxen.com/englishlistening/cnn/index"
    
    var CNNNewsList = [News]() {
        didSet {
            self.activityIndicator.stopAnimating()
            CNNNewsTableView.reloadData()
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
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .ballRotateChase, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.lightGray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
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
                        var name = ""
                        if components.count != 1 {
                            name = components[1]
                        }else {
                            components = innerHtml.components(separatedBy: "\"")
                            name = components[1]
                        }
                        components = innerHtml.components(separatedBy: "\"")
                        let CNNNewsItem = News.init(name: name, url: "http://www.hxen.com" + components[3], isLiked: false)
                        self.CNNNewsList.append(CNNNewsItem)
                    }
                }
            }
            
            for index in 0 ..< self.CNNNewsList.count {
                if self.CNNNewsList[index].name.contains("¡¯") {
                    self.CNNNewsList[index].name = self.CNNNewsList[index].name.replacingOccurrences(of: "¡¯", with: "\'")
                }
                if self.CNNNewsList[index].name.contains("CNN News:") {
                    self.CNNNewsList[index].name = self.CNNNewsList[index].name.replacingOccurrences(of: "CNN News:", with: "CNN新闻：")
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
                        var name = ""
                        if components.count != 1 {
                            name = components[1]
                        }else {
                            components = innerHtml.components(separatedBy: "\"")
                            name = components[1]
                        }
                        components = innerHtml.components(separatedBy: "\"")
                        let CNNNewsItem = News.init(name: name, url: "http://www.hxen.com" + components[3], isLiked: false)
                        self.CNNNewsList.append(CNNNewsItem)
                    }
                }
                self.page += 1
            }
            
            for index in 0 ..< self.CNNNewsList.count {
                if self.CNNNewsList[index].name.contains("¡¯") {
                    self.CNNNewsList[index].name = self.CNNNewsList[index].name.replacingOccurrences(of: "¡¯", with: "\'")
                }
                if self.CNNNewsList[index].name.contains("CNN News:") {
                    self.CNNNewsList[index].name = self.CNNNewsList[index].name.replacingOccurrences(of: "CNN News:", with: "CNN新闻：")
                }
            }
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CNNNewsList.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let identifier = "CNNNewsCell"
        let hsCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CNNNewsTableViewCell
        var tempCell: CNNNewsTableViewCell
        hsCell != nil ? (tempCell = hsCell!) : (tempCell = CNNNewsTableViewCell())
        tempCell.nameLabel.text = CNNNewsList[indexPath.row].name
        
        let components = CNNNewsList[indexPath.row].url.components(separatedBy: "/")
        var date = components[5]
        if !date.contains("-") {
            let year = date[date.startIndex ... date.index(date.startIndex, offsetBy: 3)]
            let month = date[date.index(date.startIndex, offsetBy: 4) ... date.index(date.startIndex, offsetBy: 5)]
            let day = date[date.index(date.startIndex, offsetBy: 6) ... date.index(date.startIndex, offsetBy: 7)]
            date = String(year + "-" + month + "-" + day)
        }
        
        tempCell.dateLabel.text = date
        tempCell.heartImageView.isHidden = CNNNewsList[indexPath.row].isLiked ? false : true
        
        tempCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
        tempCell.layoutIfNeeded()
        return tempCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CNNNewsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CNNNewsTableViewCell
        
        // Configure the cell...
        cell.nameLabel.text = CNNNewsList[indexPath.row].name
        
        let components = CNNNewsList[indexPath.row].url.components(separatedBy: "/")
        var date = components[5]
        if !date.contains("-") {
            let year = date[date.startIndex ... date.index(date.startIndex, offsetBy: 3)]
            let month = date[date.index(date.startIndex, offsetBy: 4) ... date.index(date.startIndex, offsetBy: 5)]
            let day = date[date.index(date.startIndex, offsetBy: 6) ... date.index(date.startIndex, offsetBy: 7)]
            date = String(year + "-" + month + "-" + day)
        }
        cell.dateLabel.text = date
        cell.heartImageView.isHidden = CNNNewsList[indexPath.row].isLiked ? false : true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = CNNNewsList.count - 1
        if indexPath.row == lastElement {
            activityIndicator.startAnimating()
            // handle your logic here to get more items, add it to dataSource and reload tableview
            print(page)
            loadMore(url: url + "_\(page)")
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let checkInAction = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath) as! CNNNewsTableViewCell
            self.CNNNewsList[indexPath.row].isLiked = (self.CNNNewsList[indexPath.row].isLiked) ? false : true
            cell.heartImageView.isHidden = self.CNNNewsList[indexPath.row].isLiked ? false : true
            
            completionHandler(true)
        }
        
        let checkInIcon = CNNNewsList[indexPath.row].isLiked ? "undo" : "tick"
        checkInAction.backgroundColor = UIColor(red: 38, green: 162, blue: 78)
        checkInAction.image = UIImage(named: checkInIcon)
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [checkInAction])
        
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        return UISwipeActionsConfiguration.init()
    }
}

extension CNNNewsController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCNNNewsDetail" {
            if let indexPath = CNNNewsTableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! NewsDetailViewController
                destinationController.newsItems = CNNNewsList
                destinationController.indexOfnews = indexPath.row
                destinationController.newsItemName = CNNNewsList[indexPath.row].name
                destinationController.newsItemURL = CNNNewsList[indexPath.row].url
                destinationController.newsType = "CNNNews"
            }
        }
    }
}

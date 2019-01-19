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
    
    var VOANewsList = [VOANews]() {
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
        let url = "http://www.hxen.com/englishlistening/voaenglish/voastandardenglish/index"
        
        Alamofire.request((url + ".html"), method: .get).responseString { response in
            if let error = response.error {
                if error.localizedDescription == "The Internet connection appears to be offline." {
                    print("未连接网络")
                }
            }
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
                for content in doc.css(".fz18") {
                    if let innerHtml = content.innerHTML {
                        let components = innerHtml.components(separatedBy: "\"")
                        let VOANewsItem = VOANews.init(name: components[1], url: "http://www.hxen.com" + components[3], isLiked: false)
                        self.VOANewsList.append(VOANewsItem)
                    }
                }
            }
            
            for index in 0 ..< self.VOANewsList.count {
                if self.VOANewsList[index].name.contains("¡¯") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "¡¯", with: "\'")
                }
                if self.VOANewsList[index].name.contains("VOA³£ËÙÓ¢Óï:") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "VOA³£ËÙÓ¢Óï:", with: "")
                }
                
                print(self.VOANewsList[index].name)
                print(self.VOANewsList[index].url)
            }
        }
        loadDataTimes += 1
    }
    
    func loadMore(url: String) {
        Alamofire.request((url + ".html"), method: .get).responseString { response in
            if let error = response.error {
                if error.localizedDescription == "The Internet connection appears to be offline." {
                    print("未连接网络")
                }
            }
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
                for content in doc.css(".fz18") {
                    if let innerHtml = content.innerHTML {
                        let components = innerHtml.components(separatedBy: "\"")
                        let VOANewsItem = VOANews.init(name: components[1], url: "http://www.hxen.com" + components[3], isLiked: false)
                        self.VOANewsList.append(VOANewsItem)
                    }
                }
            }
            
            for index in 0 ..< self.VOANewsList.count {
                if self.VOANewsList[index].name.contains("¡¯") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "¡¯", with: "\'")
                }
                if self.VOANewsList[index].name.contains("VOA³£ËÙÓ¢Óï:") {
                    self.VOANewsList[index].name = self.VOANewsList[index].name.replacingOccurrences(of: "VOA³£ËÙÓ¢Óï:", with: "")
                }
                
                print(self.VOANewsList[index].name)
                print(self.VOANewsList[index].url)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "VOANewsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! VOANewsTableViewCell
        
        // Configure the cell...
        cell.nameLabel.text = VOANewsList[indexPath.row].name
        
        let components = VOANewsList[indexPath.row].url.components(separatedBy: "/")
        cell.dateLabel.text = components[6]
        cell.heartImageView.isHidden = VOANewsList[indexPath.row].isLiked ? false : true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(VOANewsList[indexPath.row].url)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = VOANewsList.count - 1
        if indexPath.row == lastElement {
            activityIndicator.startAnimating()
            // handle your logic here to get more items, add it to dataSource and reload tableview
            loadMore(url: "http://www.hxen.com/englishlistening/voaenglish/voastandardenglish/index" + "_\(page)")
            page += 1
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let checkInAction = UIContextualAction(style: .normal, title: "Check-in") { (action, sourceView, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath) as! VOANewsTableViewCell
            self.VOANewsList[indexPath.row].isLiked = (self.VOANewsList[indexPath.row].isLiked) ? false : true
            cell.heartImageView.isHidden = self.VOANewsList[indexPath.row].isLiked ? false : true
            
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
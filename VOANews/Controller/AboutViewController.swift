//
//  AboutViewController.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/31.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var aboutTableView: UITableView!
    
    var sectionTitles = [NSLocalizedString("Feedback", comment: "Feedback"), NSLocalizedString("Follow Us", comment: "Follow Us")]
    var sectionContent = [[(image: "store", text: NSLocalizedString("Rate us on App Store", comment: "Rate us on App Store"), link: "itms-apps://itunes.apple.com/app/id1450747369")],
                          [(image: "weibo", text: NSLocalizedString("Weibo", comment: "Weibo"), link: "https://weibo.com/u/3319290365"),
                           (image: "twitter", text: NSLocalizedString("Twitter", comment: "Twitter"), link: "https://twitter.com/Albertyujx"),
                           (image: "instagram", text: NSLocalizedString("Instagram", comment: "Instagram"), link: "https://www.instagram.com/alberty573/")]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        aboutTableView.delegate = self
        aboutTableView.dataSource = self
        aboutTableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionContent[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let link = sectionContent[indexPath.section][indexPath.row].link
        
        switch indexPath.section {
        // Leave us feedback section
        case 0:
            if indexPath.row == 0 {
                if let url = URL(string: link) {
                    UIApplication.shared.open(url)
                }
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "showWebView", sender: self)
            }
            
        // Follow us section
        case 1:
            if let url = URL(string: link) {
                let safariController = SFSafariViewController(url: url)
                present(safariController, animated: true, completion: nil)
            }
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
        
        // Configure the cell...
        let cellData = sectionContent[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellData.text
        cell.imageView?.image = UIImage(named: cellData.image)
        
        return cell
    }
}

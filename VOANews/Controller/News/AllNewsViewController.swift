//
//  AllNewsViewController.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/30.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit

class AllNewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "AllNewsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AllNewsTableViewCell
        switch indexPath.row {
        case 0:
            cell.newsIconImageView.image = UIImage(named: "letterV")
            cell.newsNameLabel.text = "VOA News"
        case 1:
            cell.newsIconImageView.image = UIImage(named: "letterB")
            cell.newsNameLabel.text = "BBC News"
        case 2:
            cell.newsIconImageView.image = UIImage(named: "letterC")
            cell.newsNameLabel.text = "CNN News"
        case 3:
            cell.newsIconImageView.image = UIImage(named: "letterA")
            cell.newsNameLabel.text = "As It Is"
        case 4:
            cell.newsIconImageView.image = UIImage(named: "letterS")
            cell.newsNameLabel.text = "Scientific American"
        case 5:
            cell.newsIconImageView.image = UIImage(named: "letterT")
            cell.newsNameLabel.text = "The Economist"
        case 6:
            cell.newsIconImageView.image = UIImage(named: "letterC")
            cell.newsNameLabel.text = "CRI News"
        default:
            cell.newsIconImageView.image = UIImage(named: "")
            cell.newsNameLabel.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var targetVC = storyboard.instantiateInitialViewController()
        switch indexPath.row {
        case 0:
            targetVC = storyboard.instantiateViewController(withIdentifier :"VOANewsController") as! VOANewsController
        case 1:
            targetVC = storyboard.instantiateViewController(withIdentifier :"BBCNewsController") as! BBCNewsController
        case 2:
            targetVC = storyboard.instantiateViewController(withIdentifier :"CNNNewsController") as! CNNNewsController
        case 3:
            targetVC = storyboard.instantiateViewController(withIdentifier :"AsItIsController") as! AsItIsViewController
        case 4:
            targetVC = storyboard.instantiateViewController(withIdentifier :"ScientificAmericanViewController") as! ScientificAmericanViewController
        case 5:
            targetVC = storyboard.instantiateViewController(withIdentifier :"TheEconomistViewController") as! TheEconomistViewController
        case 6:
            targetVC = storyboard.instantiateViewController(withIdentifier :"CRINewsViewController") as! CRINewsViewController
        default:
            targetVC = storyboard.instantiateViewController(withIdentifier :"AllNewsViewController") as! AllNewsViewController
        }
        self.present(targetVC!, animated: true, completion: nil)
    }
    
    @IBOutlet var NewsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NewsTableView.delegate = self
        NewsTableView.dataSource = self
        favoriteNews = DataManager.shared.getAllFavorateNews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if !UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
                
                present(walkthroughViewController, animated: true, completion: nil)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

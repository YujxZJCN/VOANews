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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = "AllNewsCell"
        switch indexPath.row {
        case 0:
            identifier = "AllNewsOfVOANewsCell"
        case 1:
            identifier = "AllNewsOfBBCNewsCell"
        case 2:
            identifier = "AllNewsOfCNNNewsCell"
        case 3:
            identifier = "AllNewsOfAsItIsCell"
        default:
            break
        }
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AllNewsOfVOANewsTableViewCell
            cell.NewsNameLabel.text = "VOA News"
            cell.VOANewsIconImageView.image = UIImage(named: "letterV")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AllNewsOfBBCNewsTableViewCell
            cell.NewsNameLabel.text = "BBC News"
            cell.BBCNewsIconImageView.image = UIImage(named: "letterB")
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AllNewsOfCNNNewsTableViewCell
            cell.NewsNameLabel.text = "CNN News"
            cell.CNNNewxIconImageView.image = UIImage(named: "letterC")
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AllNewsOfAsItIsTableViewCell
            cell.NewsNameLabel.text = "As It Is"
            cell.AsItIsIconImageView.image = UIImage(named: "letterA")
            return cell
        default:
            return UITableViewCell.init()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

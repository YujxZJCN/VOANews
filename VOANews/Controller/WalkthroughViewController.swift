//
//  WalkthroughViewController.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/25.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController, WalkthroughPageViewControllerDelegate {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 25.0
            nextButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var skipButton: UIButton!
    
    var walkthroughPageViewController: WalkthroughPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nextButton.setTitle(NSLocalizedString("NEXT", comment: "NEXT"), for: .normal)
        skipButton.setTitle(NSLocalizedString("Skip", comment: "Skip"), for: .normal)
    }
    // Portrait only
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait //return the value as per the required orientation
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                walkthroughPageViewController?.forwardPage()
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                dismiss(animated: true, completion: nil)
            default: break
            }
        }
        
        updateUI()
    }
    
    func updateUI() {
        
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                nextButton.setTitle(NSLocalizedString("NEXT", comment: "NEXT"), for: .normal)
                skipButton.isHidden = false
            case 2:
                nextButton.setTitle(NSLocalizedString("GET STARTED", comment: "GET STARTED"), for: .normal)
                skipButton.isHidden = true
            default: break
            }
            
            pageControl.currentPage = index
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
    
//    // MARK: - 3D Touch
//
//    func createQuickActions() {
//
//        // Add Quick Actions
//        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
//            if let bundleIdentifier = Bundle.main.bundleIdentifier {
//                let shortcutItem1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).VOANews", localizedTitle: "VOA News", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "VOANewsIcon"), userInfo: nil)
//                let shortcutItem2 = UIApplicationShortcutItem(type: "\(bundleIdentifier).BBCNews", localizedTitle: "BBC News", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "BBCNewsIcon"), userInfo: nil)
//                let shortcutItem3 = UIApplicationShortcutItem(type: "\(bundleIdentifier).CNNNews", localizedTitle: "CNN News", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "CNNNewsIcon"), userInfo: nil)
//                let shortcutItem4 = UIApplicationShortcutItem(type: "\(bundleIdentifier).FavorateNews", localizedTitle: NSLocalizedString("Favorate News", comment: "Favorate News"), localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .favorite), userInfo: nil)
//                UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2, shortcutItem3, shortcutItem4]
//            }
//        }
//    }
//
    
}

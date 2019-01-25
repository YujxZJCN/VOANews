//
//  WalkthroughPageViewController.swift
//  VOANews
//
//  Created by 俞佳兴 on 2019/1/25.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit

protocol WalkthroughPageViewControllerDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkthroughPageViewController: UIPageViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageHeadings = [NSLocalizedString("Pick the news you like", comment: "Pick the news you like"),
                        NSLocalizedString("Click to play", comment: "Click to play"),
                        NSLocalizedString("Manage your favorate", comment: "Manage your favorate"),
                        ]
    
    var pageImages = ["onboarding-1", "onboarding-2", "onboarding-3"]
    
    
    var pageSubHeadings = [NSLocalizedString("Whether it is VOA, BBC or CNN", comment: "Whether it is VOA, BBC or CNN"),
                           NSLocalizedString("Speed up, slow down or stop", comment: "Speed up, slow down or stop"),
                           NSLocalizedString("I only want to listen to my favorate news", comment: "I only want to listen to my favorate news")]
    
    var currentIndex = 0
    
    weak var walkthroughDelegate: WalkthroughPageViewControllerDelegate?
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? WalkthroughContentViewController {
                
                currentIndex = contentViewController.index
                
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: contentViewController.index)
            }
            
        }
    }
    
    func contentViewController(at index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageHeadings.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.subHeading = pageSubHeadings[index]
            pageContentViewController.index = index
            
            return pageContentViewController
        }
        
        return nil
    }
    
    func forwardPage() {
        currentIndex += 1
        if let nextViewController = contentViewController(at: currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set the data source to itself
        dataSource = self
        delegate = self
        // Create the first walkthrough screen
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
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

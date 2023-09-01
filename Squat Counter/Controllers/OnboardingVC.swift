//
//  OnboardingVC.swift
//  Squat Counter
//
//  Created by sam hastings on 22/08/2023.
//

import UIKit
import HorizonCalendar

class OnboardingVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var orderedViewControllers: [UIViewController] = {
        // You can adjust the content of these view controllers based on your requirements.
        let vc1 = OnboardingContentVC()
        vc1.pageIndex = 0
        vc1.titleText = "Welcome to Squatify"
        // setup other properties as needed
        
        let vc2 = OnboardingContentVC()
        vc2.pageIndex = 1
        vc2.titleText = "How it works"
        vc2.descriptionText = "Place your device in a stable position so that your entire body is visible to the front facing camera. Start squatting and your repetitions will be counted automatically."
        vc2.showAccessButton = true
        
        let vc3 = OnboardingContentVC()
        vc3.pageIndex = 2
        vc3.titleText = "Automatically start rest intervals"
        vc3.descriptionText = "Set a rep target before you begin your workout to automatically start a rest timer once you have completed your reps for each set."
        
        return [vc1, vc2, vc3]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        // Create the skip button
        let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skipOnboarding))
        skipButton.tintColor = .orange
        self.navigationItem.rightBarButtonItem = skipButton
    }
    
    @objc func skipOnboarding() {
        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
            let tabBarController = sceneDelegate.setupMainTabBarController()
            sceneDelegate.window?.rootViewController = tabBarController
        }
    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = (viewController as? OnboardingContentVC)?.pageIndex else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = (viewController as? OnboardingContentVC)?.pageIndex else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard orderedViewControllers.count != nextIndex else {
            return nil
        }
        
        guard orderedViewControllers.count > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0  // start at the first dot
    }
}


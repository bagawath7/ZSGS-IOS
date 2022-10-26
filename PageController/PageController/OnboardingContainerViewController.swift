//
//  ViewController.swift
//  PageController
//
//  Created by zs-mac-4 on 29/09/22.
//

import UIKit
protocol OnboardingContainerViewControllerDelegate: AnyObject {
    func didFinishOnboarding()
}
class OnboardingContainerViewController: UIViewController {
    var pageViewController: UIPageViewController!
    var pages: [UIViewController]!
    var currentVC: UIViewController!
    weak var delegate: OnboardingContainerViewControllerDelegate?
    
    let closeButton = UIButton(type: .system)



    override func viewDidLoad() {
    super.viewDidLoad()
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        // Do any additional setup after loading the view.
        let page1 = OnboardingView(Image: "delorean", content: "Roads were made for journeys, not destinations")
        let page2 = OnboardingView(Image: "world", content: "Not all those who wander are lost")
        let page3 = OnboardingView(Image: "thumbs", content:"Like Share")
        pages = [UIViewController]()
        
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
        currentVC = pages.first!
        setup()
        style()
        layout()
        
    }
    private func setup() {
        view.backgroundColor = .systemPurple
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.dataSource = self
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: pageViewController.view.topAnchor),
            view.leadingAnchor.constraint(equalTo: pageViewController.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: pageViewController.view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: pageViewController.view.bottomAnchor),
        ])
        
        pageViewController.setViewControllers([currentVC], direction: .forward, animated: false, completion: nil)
        currentVC = pages.first!
    }
    private func style() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: [])
        closeButton.addTarget(self, action: #selector(closeTapped), for: .primaryActionTriggered)
    }
    
    private func layout() {
        view.addSubview(closeButton)

        // Close
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            closeButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2)
        ])
    }
    


}
extension OnboardingContainerViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getPreviousViewController(from: viewController)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getNextViewController(from: viewController)
    }

    private func getPreviousViewController(from viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index - 1 >= 0 else { return nil }
        currentVC = pages[index - 1]
        return pages[index - 1]
    }

    private func getNextViewController(from viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index + 1 < pages.count else { return nil }
        currentVC = pages[index + 1]
        return pages[index + 1]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.firstIndex(of: self.currentVC) ?? 0
    }
}

extension OnboardingContainerViewController {
    @objc func closeTapped(_ sender: UIButton) {
        delegate?.didFinishOnboarding()
    }
}

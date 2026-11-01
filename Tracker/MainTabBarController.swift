//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Капитонов Константин on 03.11.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let trackers = TrackersViewController()
		trackers.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers.title", comment: "Вкладка трекеров"), image: UIImage.tabTrackers, tag: 0)

        let statistics = StatisticsViewController()
		statistics.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics.title", comment: "Вкладка статистики"), image: UIImage.tabStatistics, tag: 1)

        let trackersNavigation = UINavigationController(rootViewController: trackers)
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = UIColor.ypWhite
        navigationAppearance.shadowColor = .clear
        trackersNavigation.navigationBar.standardAppearance = navigationAppearance
        trackersNavigation.navigationBar.scrollEdgeAppearance = navigationAppearance

        viewControllers = [trackersNavigation, statistics]
		tabBar.tintColor = UIColor.ypBlue
		tabBar.unselectedItemTintColor = UIColor.ypGray

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor.ypWhite
		appearance.shadowColor = UIColor.ypLightGray
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

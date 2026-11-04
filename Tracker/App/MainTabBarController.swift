//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Капитонов Константин on 03.11.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }

    // MARK: - View controllers

    private func setupViewControllers() {
        let trackers = TrackersViewController()
        let trackersNavigation = UINavigationController(rootViewController: trackers)
        trackersNavigation.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers.title", comment: "Вкладка трекеров"),
            image: .tabTrackers,
            tag: 0
        )
        setupNavigationBarAppearance(trackersNavigation.navigationBar)

        let statistics = StatisticsViewController()
        statistics.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics.title", comment: "Вкладка статистики"),
            image: .tabStatistics,
            tag: 1
        )

        viewControllers = [trackersNavigation, statistics]
    }

    // MARK: - Appearance

    private func setupNavigationBarAppearance(_ navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = .clear

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupTabBarAppearance() {
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = .ypLightGray

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

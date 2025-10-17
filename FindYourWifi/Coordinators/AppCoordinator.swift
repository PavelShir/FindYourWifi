//
//  AppCoordinator.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 18.10.2025.
//

import UIKit
import SwiftUI

class AppCoordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        setupNavigationBarAppearance()
    }
    
    func start() {
        showLaunchScreen()
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    private func showLaunchScreen() {
        let launchView = LaunchScreen()
        let hostingController = UIHostingController(rootView: launchView)
        navigationController.setViewControllers([hostingController], animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showMainTabBar()
        }
    }
    
    private func showMainTabBar() {
        let tabBarController = UITabBarController()
        
        let deviceListView = DeviceListView { [weak self] device in
            self?.showDeviceDetail(device: device)
        }
        let devicesNav = UINavigationController(rootViewController: UIHostingController(rootView: deviceListView))
        devicesNav.tabBarItem = UITabBarItem(title: "Устройства", image: UIImage(systemName: "antenna.radiowaves.left.and.right"), tag: 0)
        
        let historyView = HistoryView()
        let historyNav = UINavigationController(rootViewController: UIHostingController(rootView: historyView))
        historyNav.tabBarItem = UITabBarItem(title: "История", image: UIImage(systemName: "clock.arrow.circlepath"), tag: 1)
        
        tabBarController.viewControllers = [devicesNav, historyNav]
        
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    private func showDeviceDetail(device: AnyHashable) {
        let detailView = DeviceDetailView(device: device)
        let hostingController = UIHostingController(rootView: detailView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}

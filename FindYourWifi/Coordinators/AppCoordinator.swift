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
    private let window: UIWindow
    
    init(window: UIWindow, navigationController: UINavigationController) {
        self.window = window
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
        
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showMainTabBar()
        }
    }
    
    private func showMainTabBar() {
        let tabBarController = UITabBarController()
        
        // MARK: - Device List
        let deviceListView = NavigationView {
            DeviceListView()
        }
        .navigationViewStyle(StackNavigationViewStyle())

        
        let deviceListController = UIHostingController(rootView: deviceListView)
        deviceListController.tabBarItem = UITabBarItem(
            title: "Устройства",
            image: UIImage(systemName: "antenna.radiowaves.left.and.right"),
            tag: 0
        )
        
        // MARK: - History
        let historyView = NavigationView {
            HistoryView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        let historyController = UIHostingController(rootView: historyView)
        historyController.tabBarItem = UITabBarItem(
            title: "История",
            image: UIImage(systemName: "clock.arrow.circlepath"),
            tag: 1
        )
        
        tabBarController.viewControllers = [deviceListController, historyController]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

}

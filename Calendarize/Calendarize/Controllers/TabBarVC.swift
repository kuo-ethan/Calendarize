//
//  TabBarVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation
import UIKit

/// The initial launch screen for a signed in user, which defaults to the Home screen.
class TabBarVC: UITabBarController {
    
    let wrappedHomeVC: UINavigationController = {
        let homeVC = HomeVC()
        HomeVC.shared = homeVC
        let wrappedHomeVC = UINavigationController(rootViewController: homeVC)
        wrappedHomeVC.title = "Home"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = nil
        
        let navigationBar = wrappedHomeVC.navigationBar
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        
        return wrappedHomeVC
    }()
    
    let wrappedTasksVC: UINavigationController = {
        let tasksVC = TasksVC()
        TasksVC.shared = tasksVC
        let wrappedTasksVC = UINavigationController(rootViewController: tasksVC)
        wrappedTasksVC.title = "Tasks"
        
        return wrappedTasksVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewControllers([wrappedHomeVC, wrappedTasksVC], animated: true)
        self.selectedViewController = wrappedHomeVC
        
        guard let items = tabBar.items else { return }
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.shadowColor = nil
        
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        
        items[0].standardAppearance = tabBarAppearance
        
        let calendarImage = UIImage(systemName: "calendar")
        let todoListImage = UIImage(systemName: "list.bullet")
        
        items[0].image = calendarImage
        items[1].image = todoListImage
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == tabBar.items?[0] {
            Database.shared.updateUser(Authentication.shared.currentUser!, nil)
        } else if item == tabBar.items?[1] {
            TasksVC.shared.tableView.reloadData() // This is blocking/synchronous
            wrappedHomeVC.popToRootViewController(animated: false) // Switching back to Home displays calendar
        }
    }
}


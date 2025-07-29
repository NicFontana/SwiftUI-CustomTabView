//
//  UITabBarControllerRepresentable.swift
//  
//
//  Created by Niccolò Fontana on 19/01/23.
//

#if os(iOS)
import SwiftUI

@available(iOS 13.0, *)
struct UITabBarControllerRepresentable: UIViewControllerRepresentable {
    let selectedTabIndex: Int
    let subviews: _VariadicView_Children
    
    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(subviews.map { UIHostingController(rootView: $0) }, animated: false)
        tabBarController.selectedIndex = selectedTabIndex
        tabBarController.tabBar.isHidden = true
        return tabBarController
    }
    
    func updateUIViewController(_ tabBarController: UITabBarController, context: Context) {
        if let viewControllers = tabBarController.viewControllers {
            for i in viewControllers.indices {
                (viewControllers[i] as? UIHostingController)?.rootView = subviews[i]
            }
        }
        tabBarController.selectedIndex = selectedTabIndex
    }
}

@available(iOS 18.0, *)
struct UITabBarControllerRepresentable_iOS18: UIViewControllerRepresentable {
    let selectedTabIndex: Int
    let subviews: SubviewsCollection
    
    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(subviews.map { UIHostingController(rootView: $0) }, animated: false)
        tabBarController.selectedIndex = selectedTabIndex
        tabBarController.tabBar.isHidden = true
        tabBarController.isTabBarHidden = true
        return tabBarController
    }
    
    func updateUIViewController(_ tabBarController: UITabBarController, context: Context) {
        if let viewControllers = tabBarController.viewControllers {
            for i in viewControllers.indices {
                (viewControllers[i] as? UIHostingController)?.rootView = subviews[i]
            }
        }
        tabBarController.selectedIndex = selectedTabIndex
    }
}
#endif

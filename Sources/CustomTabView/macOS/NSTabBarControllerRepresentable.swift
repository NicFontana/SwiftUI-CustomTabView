//
//  NSTabBarControllerRepresentable.swift
//  
//
//  Created by Niccolò Fontana on 18/02/23.
//

#if os(macOS)
import SwiftUI

@available(macOS 10.15, *)
struct NSTabViewControllerRepresentable: NSViewControllerRepresentable {
    let selectedTabIndex: Int
    let subviews: _VariadicView_Children
    
    func makeNSViewController(context: Context) -> NSTabViewController {
        let tabViewController = NSTabViewController()
        subviews.forEach {
            tabViewController.addChild(NSHostingController(rootView: $0))
        }
        tabViewController.tabStyle = .unspecified
        tabViewController.selectedTabViewItemIndex = selectedTabIndex
        return tabViewController
    }
    
    func updateNSViewController(_ tabViewController: NSTabViewController, context: Context) {
        for i in tabViewController.children.indices {
            (tabViewController.children[i] as? NSHostingController)?.rootView = subviews[i]
        }
        tabViewController.selectedTabViewItemIndex = selectedTabIndex
    }
}

@available(macOS 15.0, *)
struct NSTabViewControllerRepresentable_macOS15: NSViewControllerRepresentable {
    let selectedTabIndex: Int
    let subviews: SubviewsCollection
    
    func makeNSViewController(context: Context) -> NSTabViewController {
        let tabViewController = NSTabViewController()
        subviews.forEach {
            tabViewController.addChild(NSHostingController(rootView: $0))
        }
        tabViewController.tabStyle = .unspecified
        tabViewController.selectedTabViewItemIndex = selectedTabIndex
        return tabViewController
    }
    
    func updateNSViewController(_ tabViewController: NSTabViewController, context: Context) {
        for i in tabViewController.children.indices {
            (tabViewController.children[i] as? NSHostingController)?.rootView = subviews[i]
        }
        tabViewController.selectedTabViewItemIndex = selectedTabIndex
    }
}
#endif

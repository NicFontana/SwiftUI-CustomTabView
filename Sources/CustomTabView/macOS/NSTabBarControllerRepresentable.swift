//
//  NSTabBarControllerRepresentable.swift
//  
//
//  Created by Niccolò Fontana on 18/02/23.
//

#if canImport(AppKit)
import SwiftUI
import AppKit

@available(macOS 10.15, *)
struct NSTabViewControllerRepresentable: NSViewControllerRepresentable {
    let selectedTabIndex: Int
    let controlledViews: [NSViewController]
    
    func makeNSViewController(context: Context) -> NSTabViewController {
        let tabViewController = NSTabViewController()
        controlledViews.forEach { tabViewController.addChild($0) }
        tabViewController.tabStyle = .unspecified
        tabViewController.selectedTabViewItemIndex = selectedTabIndex
        return tabViewController
    }
    
    func updateNSViewController(_ tabViewController: NSTabViewController, context: Context) {
        tabViewController.selectedTabViewItemIndex = selectedTabIndex
    }
}

@available(macOS 10.15, *)
struct NSTabViewControllerRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        NSTabViewControllerRepresentable(selectedTabIndex: 0, controlledViews: [])
    }
}
#endif

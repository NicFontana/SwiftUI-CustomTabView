//
//  CustomTabView.swift
//  
//
//  Created by Niccolò Fontana on 19/01/23.
//

import SwiftUI

/// A SwiftUI component that enables users to create a customizable TabView with a user-defined TabBar.
/// This component allows developers to specify a custom TabBar view and associate it with specific tabs.
///
/// ## Example Usage
/// ```swift
/// @State private var selection: String = "Tab1"
///
/// CustomTabView(
///    tabBarView: MyCustomTabBar(selection: $selection),
///    tabs: ["Tab1", "Tab2", "Tab3"],
///    selection: selection
/// ) {
///    // Content for each tab
///    Text("Content for Tab1")
///
///    Text("Content for Tab2")
///
///    Text("Content for Tab3")
/// }
/// ```
/// 
/// - Parameters:
///   - tabBarView: The custom view that will serve as the tab bar.
///   - tabs: An array of values conforming to `Hashable` that represent the tabs. The order of tabs in this array **must** be reflected in the TabBar view provided.
///   - selection: The currently selected tab.
///   - content: A closure that provides the content for each tab. The order and number of elements in the closure **must** match the `tabs` parameter.
@available(iOS 13.0, macOS 10.15, *)
public struct CustomTabView<SelectionValue: Hashable, TabBarView: View, Content: View>: View {
    
    // Tabs
    let selection: SelectionValue
    private let tabIndices: [SelectionValue: Int]
    
    // TabBar
    let tabBarView: TabBarView
    
    // Content
    let content: Content
    
    public init(tabBarView: TabBarView, tabs: [SelectionValue], selection: SelectionValue, @ViewBuilder content: () -> Content) {
        self.tabBarView = tabBarView
        self.selection = selection
        self.content = content()
        
        var tabIndices: [SelectionValue: Int] = [:]
        for (index, tab) in tabs.enumerated() {
            tabIndices[tab] = index
        }
        self.tabIndices = tabIndices
    }
    
    public var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            Group(subviews: content) { subviews in
                _LayoutView<TabBarView, SelectionValue>(
                    tabBarView: tabBarView,
                    selectedTabIndex: tabIndices[selection] ?? 0,
                    children: subviews
                )
            }
        } else {
            _VariadicView.Tree(
                _VariadicViewLayout<TabBarView, SelectionValue>(
                    tabBarView: tabBarView,
                    selectedTabIndex: tabIndices[selection] ?? 0
                )
            ) {
                content
            }
        }
    }
}

private struct _VariadicViewLayout<TabBarView: View, SelectionValue: Hashable>: _VariadicView_UnaryViewRoot {
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
    @Environment(\.tabBarPosition) private var tabBarPosition: TabBarPosition
    
    let tabBarView: TabBarView
    let selectedTabIndex: Int
    
    private func contentView(children: _VariadicView.Children) -> some View {
        #if canImport(UIKit)
        return UITabBarControllerRepresentable(
            selectedTabIndex: selectedTabIndex,
            controlledViews: children.map { UIHostingController(rootView: $0) }
        )
        #elseif canImport(AppKit)
        return NSTabViewControllerRepresentable(
            selectedTabIndex: selectedTabIndex,
            controlledViews: children.map { NSHostingController(rootView: $0) }
        )
        #endif
    }
    
    private func topBarView(children: _VariadicView.Children) -> some View {
        VStack(spacing: 0) {
            tabBarView
            
            contentView(children: children)
        }
    }
    
    private func bottomBarView(children: _VariadicView.Children) -> some View {
        VStack(spacing: 0) {
            contentView(children: children)
            
            tabBarView
        }
    }
    
    #if canImport(UIKit)
    // Keyboard visibility
    @State private var isKeyboardVisible: Bool = false
    
    private func bottomBarViewiOS13(children: _VariadicView.Children) -> some View {
        VStack(spacing: 0) {
            contentView(children: children)
            
            if !isKeyboardVisible {
                tabBarView
            }
        }
        .onReceive(keyboardPublisher) { isKeyboardVisible in
            self.isKeyboardVisible  = isKeyboardVisible
        }
    }
    #endif
    
    private func leftBarView(children: _VariadicView.Children) -> some View {
        HStack(spacing: 0) {
            tabBarView
            
            contentView(children: children)
        }
    }
    
    private func rightBarView(children: _VariadicView.Children) -> some View {
        HStack(spacing: 0) {
            contentView(children: children)
            
            tabBarView
        }
    }
    
    private func floatingBarView(children: _VariadicView.Children, edge: Edge) -> some View {
        let alignment: Alignment
        switch edge {
        case .top:
            alignment = .top
        case .leading:
            alignment = .leading
        case .bottom:
            alignment = .bottom
        case .trailing:
            alignment = .trailing
        }
        
        return ZStack(alignment: alignment, content: {
            contentView(children: children)
            
            tabBarView
        })
    }
    
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        switch tabBarPosition {
        case .edge(let edge):
            switch edge {
            case .top:
                topBarView(children: children)
            case .leading:
                switch layoutDirection {
                case .leftToRight:
                    leftBarView(children: children)
                case .rightToLeft:
                    rightBarView(children: children)
                @unknown default:
                    leftBarView(children: children)
                }
            case .bottom:
                #if canImport(UIKit)
                if #available(iOS 14, *) {
                    bottomBarView(children: children)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                } else {
                    bottomBarViewiOS13(children: children)
                }
                #elseif canImport(AppKit)
                bottomBarView(children: children)
                #endif
            case .trailing:
                switch layoutDirection {
                case .leftToRight:
                    rightBarView(children: children)
                case .rightToLeft:
                    leftBarView(children: children)
                @unknown default:
                    rightBarView(children: children)
                }
            }
        case .floating(let edge):
            floatingBarView(children: children, edge: edge)
        }
    }
}

#if canImport(UIKit)
extension _CustomTabViewLayout: KeyboardReadable {}
#endif

@available(iOS 18.0, macOS 15.0, *)
private struct _LayoutView<TabBarView: View, SelectionValue: Hashable>: View {
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
    @Environment(\.tabBarPosition) private var tabBarPosition: TabBarPosition
    
    let tabBarView: TabBarView
    let selectedTabIndex: Int
    let children: SubviewsCollection

    private func contentView(children: SubviewsCollection) -> some View {
        #if canImport(UIKit)
        return UITabBarControllerRepresentable(
            selectedTabIndex: selectedTabIndex,
            controlledViews: children.map { UIHostingController(rootView: $0) }
        )
        #elseif canImport(AppKit)
        return NSTabViewControllerRepresentable(
            selectedTabIndex: selectedTabIndex,
            controlledViews: children.map { NSHostingController(rootView: $0) }
        )
        #endif
    }
    
    private func topBarView(children: SubviewsCollection) -> some View {
        VStack(spacing: 0) {
            tabBarView
            
            contentView(children: children)
        }
    }
    
    private func bottomBarView(children: SubviewsCollection) -> some View {
        VStack(spacing: 0) {
            contentView(children: children)
            
            tabBarView
        }
    }
    
    private func leftBarView(children: SubviewsCollection) -> some View {
        HStack(spacing: 0) {
            tabBarView
            
            contentView(children: children)
        }
    }
    
    private func rightBarView(children: SubviewsCollection) -> some View {
        HStack(spacing: 0) {
            contentView(children: children)
            
            tabBarView
        }
    }
    
    private func floatingBarView(children: SubviewsCollection, edge: Edge) -> some View {
        let alignment: Alignment
        switch edge {
        case .top:
            alignment = .top
        case .leading:
            alignment = .leading
        case .bottom:
            alignment = .bottom
        case .trailing:
            alignment = .trailing
        }
        
        return ZStack(alignment: alignment, content: {
            contentView(children: children)
            
            tabBarView
        })
    }
    
    var body: some View {
        switch tabBarPosition {
        case .edge(let edge):
            switch edge {
            case .top:
                topBarView(children: children)
            case .leading:
                switch layoutDirection {
                case .leftToRight:
                    leftBarView(children: children)
                case .rightToLeft:
                    rightBarView(children: children)
                @unknown default:
                    leftBarView(children: children)
                }
            case .bottom:
                #if canImport(UIKit)
                bottomBarView(children: children)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                #elseif canImport(AppKit)
                bottomBarView(children: children)
                #endif
            case .trailing:
                switch layoutDirection {
                case .leftToRight:
                    rightBarView(children: children)
                case .rightToLeft:
                    leftBarView(children: children)
                @unknown default:
                    rightBarView(children: children)
                }
            }
        case .floating(let edge):
            floatingBarView(children: children, edge: edge)
        }
    }
}

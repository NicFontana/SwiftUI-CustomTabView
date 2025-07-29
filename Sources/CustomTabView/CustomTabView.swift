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
                    subviews: subviews
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
    
    private func contentView(subviews: _VariadicView.Children) -> some View {
        #if os(iOS)
        return UITabBarControllerRepresentable(
            selectedTabIndex: selectedTabIndex,
            subviews: subviews
        )
        #elseif os(macOS)
        return NSTabViewControllerRepresentable(
            selectedTabIndex: selectedTabIndex,
            subviews: subviews
        )
        #endif
    }
    
    private func topBarView(subviews: _VariadicView.Children) -> some View {
        VStack(spacing: 0) {
            tabBarView
            
            contentView(subviews: subviews)
        }
    }
    
    private func bottomBarView(subviews: _VariadicView.Children) -> some View {
        VStack(spacing: 0) {
            contentView(subviews: subviews)
            
            tabBarView
        }
    }
    
    #if os(iOS)
    // Keyboard visibility
    @State private var isKeyboardVisible: Bool = false
    
    private func bottomBarViewiOS13(subviews: _VariadicView.Children) -> some View {
        VStack(spacing: 0) {
            contentView(subviews: subviews)
            
            if !isKeyboardVisible {
                tabBarView
            }
        }
        .onReceive(keyboardPublisher) { isKeyboardVisible in
            self.isKeyboardVisible  = isKeyboardVisible
        }
    }
    #endif
    
    private func leftBarView(subviews: _VariadicView.Children) -> some View {
        HStack(spacing: 0) {
            tabBarView
            
            contentView(subviews: subviews)
        }
    }
    
    private func rightBarView(subviews: _VariadicView.Children) -> some View {
        HStack(spacing: 0) {
            contentView(subviews: subviews)
            
            tabBarView
        }
    }
    
    private func floatingBarView(subviews: _VariadicView.Children, edge: Edge) -> some View {
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
            contentView(subviews: subviews)
            
            tabBarView
        })
    }
    
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        switch tabBarPosition {
        case .edge(let edge):
            switch edge {
            case .top:
                topBarView(subviews: children)
            case .leading:
                switch layoutDirection {
                case .leftToRight:
                    leftBarView(subviews: children)
                case .rightToLeft:
                    rightBarView(subviews: children)
                @unknown default:
                    leftBarView(subviews: children)
                }
            case .bottom:
                #if os(iOS)
                if #available(iOS 14, *) {
                    bottomBarView(subviews: children)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                } else {
                    bottomBarViewiOS13(subviews: children)
                }
                #elseif os(macOS)
                bottomBarView(subviews: children)
                #endif
            case .trailing:
                switch layoutDirection {
                case .leftToRight:
                    rightBarView(subviews: children)
                case .rightToLeft:
                    leftBarView(subviews: children)
                @unknown default:
                    rightBarView(subviews: children)
                }
            }
        case .floating(let edge):
            floatingBarView(subviews: children, edge: edge)
        }
    }
}

#if os(iOS)
extension _VariadicViewLayout: KeyboardReadable {}
#endif

@available(iOS 18.0, macOS 15.0, *)
private struct _LayoutView<TabBarView: View, SelectionValue: Hashable>: View {
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
    @Environment(\.tabBarPosition) private var tabBarPosition: TabBarPosition
    
    let tabBarView: TabBarView
    let selectedTabIndex: Int
    let subviews: SubviewsCollection

    private func contentView(subviews: SubviewsCollection) -> some View {
        #if os(iOS)
        return UITabBarControllerRepresentable_iOS18(
            selectedTabIndex: selectedTabIndex,
            subviews: subviews
        )
        #elseif os(macOS)
        return NSTabViewControllerRepresentable_macOS15(
            selectedTabIndex: selectedTabIndex,
            subviews: subviews
        )
        #endif
    }
    
    private func topBarView(subviews: SubviewsCollection) -> some View {
        VStack(spacing: 0) {
            tabBarView
            
            contentView(subviews: subviews)
        }
    }
    
    private func bottomBarView(subviews: SubviewsCollection) -> some View {
        VStack(spacing: 0) {
            contentView(subviews: subviews)
            
            tabBarView
        }
    }
    
    private func leftBarView(subviews: SubviewsCollection) -> some View {
        HStack(spacing: 0) {
            tabBarView
            
            contentView(subviews: subviews)
        }
    }
    
    private func rightBarView(subviews: SubviewsCollection) -> some View {
        HStack(spacing: 0) {
            contentView(subviews: subviews)
            
            tabBarView
        }
    }
    
    private func floatingBarView(subviews: SubviewsCollection, edge: Edge) -> some View {
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
            contentView(subviews: subviews)
            
            tabBarView
        })
    }
    
    var body: some View {
        switch tabBarPosition {
        case .edge(let edge):
            switch edge {
            case .top:
                topBarView(subviews: subviews)
            case .leading:
                switch layoutDirection {
                case .leftToRight:
                    leftBarView(subviews: subviews)
                case .rightToLeft:
                    rightBarView(subviews: subviews)
                @unknown default:
                    leftBarView(subviews: subviews)
                }
            case .bottom:
                #if os(iOS)
                bottomBarView(subviews: subviews)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                #elseif os(macOS)
                bottomBarView(subviews: subviews)
                #endif
            case .trailing:
                switch layoutDirection {
                case .leftToRight:
                    rightBarView(subviews: subviews)
                case .rightToLeft:
                    leftBarView(subviews: subviews)
                @unknown default:
                    rightBarView(subviews: subviews)
                }
            }
        case .floating(let edge):
            floatingBarView(subviews: subviews, edge: edge)
        }
    }
}

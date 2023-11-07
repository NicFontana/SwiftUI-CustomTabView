//
//  CustomTabView.swift
//  
//
//  Created by Niccolò Fontana on 19/01/23.
//

import SwiftUI

@available(iOS 13.0, macOS 10.15, *)
public struct CustomTabView<SelectionValue: Hashable, TabBarView: View, Content: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
    
    // Tabs
    let tabs: [SelectionValue]
    @Binding var selection: SelectionValue
    private let tabIndices: [SelectionValue: Int]
    
    // TabBar
    let tabBarView: TabBarView
    let tabBarPosition: Edge
    
    // Views
    #if canImport(UIKit)
    let controlledViews: [UIViewController]
    #elseif canImport(AppKit)
    let controlledViews: [NSViewController]
    #endif
        
    public init(
        tabs: [SelectionValue],
        selection: Binding<SelectionValue>,
        tabBarView: TabBarView,
        tabBarPosition: Edge,
        @ViewBuilder viewForTab: @escaping (SelectionValue) -> Content
    ) {
        self.tabs = tabs
        self._selection = selection
        self.tabBarView = tabBarView
        self.tabBarPosition = tabBarPosition
        
        #if canImport(UIKit)
        self.controlledViews = tabs.map { UIHostingController(rootView: viewForTab($0)) }
        #elseif canImport(AppKit)
        self.controlledViews = tabs.map { NSHostingController(rootView: viewForTab($0)) }
        #endif
        
        var tabIndices: [SelectionValue: Int] = [:]
        for (index, tab) in tabs.enumerated() {
            tabIndices[tab] = index
        }
        self.tabIndices = tabIndices
    }
    
    private var contentView: some View {
        #if canImport(UIKit)
        UITabBarControllerRepresentable(
            selectedTabIndex: tabIndices[selection] ?? 0,
            controlledViews: controlledViews
        )
        #elseif canImport(AppKit)
        NSTabViewControllerRepresentable(
            selectedTabIndex: tabIndices[selection] ?? 0,
            controlledViews: controlledViews
        )
        #endif
    }
    
    private var topBarView: some View {
        VStack(spacing: 0) {
            tabBarView
            
            contentView
        }
    }
    
    private var bottomBarView: some View {
        VStack(spacing: 0) {
            contentView
            
            tabBarView
        }
    }
    
    #if canImport(UIKit)
    // Keyboard visibility
    @State private var isKeyboardVisible: Bool = false
    
    private var bottomBarViewiOS13: some View {
        VStack(spacing: 0) {
            contentView
            
            if !isKeyboardVisible {
                tabBarView
            }
        }
        .onReceive(keyboardPublisher) { isKeyboardVisible in
            self.isKeyboardVisible  = isKeyboardVisible
        }
    }
    #endif
    
    private var leftBarView: some View {
        HStack(spacing: 0) {
            tabBarView
            
            contentView
        }
    }
    
    private var rightBarView: some View {
        HStack(spacing: 0) {
            contentView
            
            tabBarView
        }
    }
    
    public var body: some View {
        switch tabBarPosition {
            case .top:
                topBarView
            case .leading:
                switch layoutDirection {
                    case .leftToRight:
                        leftBarView
                    case .rightToLeft:
                        rightBarView
                    @unknown default:
                        leftBarView
                }
            case .bottom:
            #if canImport(UIKit)
                if #available(iOS 14, *) {
                    bottomBarView
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                } else {
                    bottomBarViewiOS13
                }
            #elseif canImport(AppKit)
                bottomBarView
            #endif
            case .trailing:
                switch layoutDirection {
                    case .leftToRight:
                        rightBarView
                    case .rightToLeft:
                        leftBarView
                    @unknown default:
                        rightBarView
                }
        }
    }
}

#if canImport(UIKit)
extension CustomTabView: KeyboardReadable {}
#endif

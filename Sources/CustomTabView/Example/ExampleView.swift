//
//  ExampleView.swift
//
//
//  Created by niccolo.fontana on 07/11/23.
//

import SwiftUI

@available(iOS 13.0, macOS 11.0, *)
struct ExampleView: View {
    @State private var selectedTab: Tab = .home
    
    private var tabBarView: ExampleTabBarView {
        ExampleTabBarView(selection: $selectedTab, onTabSelection: { tab in
            print("Maybe send some analytics here")
        })
    }
    
    var body: some View {
        CustomTabView(
            tabs: Tab.allCases,
            selection: $selectedTab,
            tabBarView: tabBarView,
            tabBarPosition: .bottom
        ) { tab in
                switch tab {
                case .home:
                    Text("Home")
                case .explore:
                    NavigationView {
                        List {
                            ForEach((0..<20).map { $0 }, id: \.self) { item in
                                NavigationLink(destination: Text("Destination \(item)")) {
                                    Text("Go to \(item)")
                                }
                            }
                        }
                        #if os(iOS)
                        .navigationBarTitle("Explore")
                        #endif
                    }
                case .favourites:
                    Text("Favourites")
                case .other:
                    Text("Other")
                }
            }
    }
}

@available(iOS 13.0, macOS 11.0, *)
struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}

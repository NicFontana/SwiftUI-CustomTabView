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
        CustomTabView(tabBarView: tabBarView, tabs: Tab.allCases, selection: selectedTab) {
            Text("Home")
            
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
            
            InnerView()
            
            Text("Other")
        }
        .tabBarPosition(.top)
    }
}

struct InnerView: View {
    @State private var position: Edge = .trailing
    @Environment(\.tabBarPosition) var tabBarPosition: Edge
    
    var body: some View {
        VStack {
            Text("Favourites")

            Text("Position: \(String(describing: tabBarPosition))")
        }
    }
}

@available(iOS 13.0, macOS 11.0, *)
struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}

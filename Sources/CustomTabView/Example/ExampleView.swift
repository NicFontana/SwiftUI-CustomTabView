//
//  ExampleView.swift
//
//
//  Created by Niccolò Fontana on 07/11/23.
//

import SwiftUI

@available(iOS 13.0, macOS 11.0, *)
struct ExampleView: View {
    @State private var selectedTab: Tab = .home
    
    private var tabBarView: some View {
        BottomFloatingTabBarView(selection: $selectedTab, onTabSelection: { tab in
            print("Maybe send some analytics here")
        })
        #if os(iOS)
        .padding(.bottom, 32)
        #endif
    }
    
    var body: some View {
        CustomTabView(tabBarView: tabBarView, tabs: Tab.allCases, selection: selectedTab) {
            #if os(iOS)
            NavigationView {
                Text("Home")
                    .navigationBarTitle("Home")
            }
            #else
                Text("Home")
            #endif
            
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
            .edgesIgnoringSafeArea(.vertical)
            
            #if os(iOS)
            NavigationView {
                Text("Favourites")
                    .navigationBarTitle("Favourites")
            }
            #else
                Text("Favourites")
            #endif
            
            #if os(iOS)
            NavigationView {
                Text("Other")
                    .navigationBarTitle("Other")
            }
            #else
                Text("Other")
            #endif
        }
        .edgesIgnoringSafeArea(.vertical)
        #if os(iOS)
        .tabBarPosition(.floating(.bottom))
        .navigationViewStyle(.stack)
        #endif
    }
}

@available(iOS 13.0, macOS 11.0, *)
struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}

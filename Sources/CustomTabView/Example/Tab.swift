//
//  Tab.swift
//
//
//  Created by Niccolò Fontana on 07/11/23.
//

import SwiftUI

@available(iOS 13.0, macOS 11.0, *)
enum Tab: String, Hashable, CaseIterable {
    case home, explore, favourites, other

    var index: Int {
        switch self {
        case .home:
            return 0
        case .explore:
            return 1
        case .favourites:
            return 2
        case .other:
            return 3
        }
    }

    var label: String {
        rawValue.capitalized
    }

    var image: Image {
        switch self {
        case .home:
            Image(systemName: "house.fill")
        case .explore:
            Image(systemName: "magnifyingglass")
        case .favourites:
            Image(systemName: "heart.fill")
        case .other:
            Image(systemName: "ellipsis")
        }
    }
}

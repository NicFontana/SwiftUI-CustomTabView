//
//  EnvironmentValues+TabBarPosition.swift
//
//
//  Created by Niccolò Fontana on 07/11/23.
//

import SwiftUI

public enum TabBarPosition {
    case edge(Edge)
    case floating(Edge)
}

private struct TabBarPositionEnvironmentKey: EnvironmentKey {
    static let defaultValue: TabBarPosition = .edge(.bottom)
}

public extension EnvironmentValues {
    var tabBarPosition: TabBarPosition {
        get { self[TabBarPositionEnvironmentKey.self] }
        set { self[TabBarPositionEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func tabBarPosition(_ value: TabBarPosition) -> some View {
        environment(\.tabBarPosition, value)
    }
}

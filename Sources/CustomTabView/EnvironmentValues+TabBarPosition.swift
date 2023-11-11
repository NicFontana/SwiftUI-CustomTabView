//
//  EnvironmentValues+TabBarPosition.swift
//
//
//  Created by Niccolò Fontana on 07/11/23.
//

import SwiftUI

private struct TabBarPositionEnvironmentKey: EnvironmentKey {
    static let defaultValue: Edge = .bottom
}

public extension EnvironmentValues {
    var tabBarPosition: Edge {
        get { self[TabBarPositionEnvironmentKey.self] }
        set { self[TabBarPositionEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func tabBarPosition(_ value: Edge) -> some View {
        environment(\.tabBarPosition, value)
    }
}

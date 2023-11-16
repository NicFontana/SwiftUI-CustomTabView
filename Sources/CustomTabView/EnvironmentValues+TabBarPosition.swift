//
//  EnvironmentValues+TabBarPosition.swift
//
//
//  Created by Niccolò Fontana on 07/11/23.
//

import SwiftUI

/// An enumaration that is used to set the tab bar view position.
public enum TabBarPosition {
    /// Puts the tab bar next to the content, at one edge of the scene.
    ///
    /// - Parameter edge: The desired edge.
    case edge(Edge)
    
    /// Puts the tab bar over the content, at one edge of the scene.
    ///
    /// - Parameter edge: The desired edge.
    case floating(Edge)
}

private struct TabBarPositionEnvironmentKey: EnvironmentKey {
    static let defaultValue: TabBarPosition = .edge(.bottom)
}

public extension EnvironmentValues {
    /// Make a `TabBarPosition` available in the environment
    var tabBarPosition: TabBarPosition {
        get { self[TabBarPositionEnvironmentKey.self] }
        set { self[TabBarPositionEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the tab bar position to the view hierarchy it is applied to.
    ///
    /// Apply this modifier to the ``CustomTabView`` you have instantiated to change the default tab bar position.
    ///
    /// The default value is `TabBarPosition.edge(.bottom)`.
    ///
    /// - Parameter value: The desired ``TabBarPosition``
    /// - Returns: A view that has the given value set in its environment.
    func tabBarPosition(_ value: TabBarPosition) -> some View {
        environment(\.tabBarPosition, value)
    }
}

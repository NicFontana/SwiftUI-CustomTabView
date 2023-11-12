//
//  ExampleTabBarView.swift
//  
//
//  Created by Niccolò Fontana on 21/02/23.
//

import SwiftUI

@available(iOS 13.0, macOS 11.0, *)
struct TopIndicatorTabBarView: View {
    @Binding var selection: Tab
    let onTabSelection: (Tab) -> Void
    
    @State private var tabItemsWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            ZStack(alignment: .top) {
                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        tabBarItem(for: tab)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selection = tab
                                onTabSelection(tab)
                            }
                    }
                }
                .readSize { size in
                    tabItemsWidth = size.width / CGFloat(Tab.allCases.count)
                }

                HStack(spacing: 0) {
                    tabIndicator

                    Spacer()
                }
            }
            .padding(.horizontal)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var tabIndicator: some View {
        Rectangle()
            .fill(Color.accentColor)
            .frame(width: tabItemsWidth, height: 2)
            .offset(x: tabIndicatorXOffset)
            .animation(.spring, value: tabIndicatorXOffset)
    }

    private var tabIndicatorXOffset: CGFloat {
        tabItemsWidth * CGFloat(selection.index)
    }

    private func tabBarItem(for tab: Tab) -> some View {
        VStack(spacing: 0) {
            tab.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(.bottom, 2)

            Text(tab.label)
                .lineLimit(1)
                .font(.system(size: 10))
        }
        .foregroundColor(selection == tab ? .accentColor : .secondary)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
        .accessibility(label: Text(tab.label))
        .accessibility(addTraits: [.isButton])
    }
}

// MARK: - View + Size reading utility

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

@available(iOS 13.0, macOS 11.0, *)
struct ExampleTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopIndicatorTabBarView(selection: .constant(.home)) { _ in }
    }
}


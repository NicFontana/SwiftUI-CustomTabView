//
//  BottomFloatingTabBarView.swift
//
//
//  Created by Niccolò Fontana on 12/11/23.
//

import SwiftUI

@available(macOS 11.0, *)
struct BottomFloatingTabBarView: View {
    @Binding var selection: Tab
    let onTabSelection: (Tab) -> Void
    
    var body: some View {
        HStack {
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
        #if canImport(UIKit)
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        )
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: .secondary.opacity(0.3), radius: 10, y: 5)
        .padding(.horizontal)
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
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibility(label: Text(tab.label))
        .accessibility(addTraits: [.isButton])
    }
}

#if canImport(UIKit)
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect
    }
}
#endif

@available(iOS 13.0, macOS 11.0, *)
struct BottomFloatingTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(macOS 11.0, iOS 14.0, *) {
            BottomFloatingTabBarView(selection: .constant(.home)) { _ in }
        } else {
            Text("")
        }
    }
}

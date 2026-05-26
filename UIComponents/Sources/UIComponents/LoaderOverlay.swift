//
//  LoaderOverlay.swift
//  UIComponents
//

import SwiftUI

private struct LoaderOverlayModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    Color.black
                        .opacity(0.35)
                        .ignoresSafeArea()
                        .overlay {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                                .scaleEffect(1.4)
                        }
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

public extension View {
    func loader(isLoading: Bool) -> some View {
        modifier(LoaderOverlayModifier(isLoading: isLoading))
    }
}

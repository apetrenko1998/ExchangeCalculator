//
//  BottomSheetContainer.swift
//  UIComponents
//
//  Created by Антон Петренко on 22/05/2026.
//

import SwiftUI
import DesignSystem

public struct BottomSheetConfiguration: Sendable {
    var backgroundColor: Color
    var cornerRadius: CGFloat
    var dimOpacity: Double
    var showDragIndicator: Bool
    var dismissThreshold: CGFloat
    var animation: Animation

    public static let `default` = BottomSheetConfiguration(
        backgroundColor: Colors.backgroundWhite,
        cornerRadius: 24,
        dimOpacity: 0.4,
        showDragIndicator: true,
        dismissThreshold: 100,
        animation: .spring(response: 0.35, dampingFraction: 0.85)
    )
}

private struct BottomSheetContainer<Content: View>: View {
    @Binding var isPresented: Bool
    let configuration: BottomSheetConfiguration
    let onDismiss: (() -> Void)?
    @ViewBuilder let content: () -> Content

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            if configuration.showDragIndicator {
                dragIndicator
            }
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
        .background(configuration.backgroundColor)
        .clipShape(
            RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)
        )
        .offset(y: dragOffset)
        .gesture(dragGesture)
    }

    // MARK: - Private

    private var dragIndicator: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.5))
            .frame(width: 36, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard value.translation.height > 0 else { return }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                if value.translation.height > configuration.dismissThreshold {
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func dismiss() {
        withAnimation(configuration.animation) {
            isPresented = false
        }
        onDismiss?()
    }
}

// MARK: - ViewModifier

private struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let configuration: BottomSheetConfiguration
    let onDismiss: (() -> Void)?
    @ViewBuilder let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack(alignment: .bottom) {
                    if isPresented {
                        Color.black
                            .opacity(configuration.dimOpacity)
                            .ignoresSafeArea()
                            .onTapGesture { dismiss() }
                            .transition(.opacity)

                        BottomSheetContainer(
                            isPresented: $isPresented,
                            configuration: configuration,
                            onDismiss: onDismiss,
                            content: sheetContent
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .animation(configuration.animation, value: isPresented)
    }

    private func dismiss() {
        isPresented = false
        onDismiss?()
    }
}

// MARK: - View Extension (public API)

public extension View {
    public func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        configuration: BottomSheetConfiguration = .default,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            BottomSheetModifier(
                isPresented: isPresented,
                configuration: configuration,
                onDismiss: onDismiss,
                sheetContent: content
            )
        )
    }
}

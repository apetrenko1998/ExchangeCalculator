import SwiftUI
import DesignSystem
import Utilities

protocol SelectableItem: Identifiable, Equatable {
    var imageName: String { get }
    var title: String { get }
}

struct CurrencySelectorView<T: SelectableItem>: View {

    let items: [T]
    let selection: T
    @Binding var isPresented: Bool
    let onSelect: (T) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            list
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(Colors.backgroundWhite)
    }

    private var header: some View {
        HStack {
            Text(AttributedStringHelper.makeSubTitleAttributedString(for: "chooseCurrency"))
            Spacer()
            Button {
                isPresented = false
            } label: {
                Image("cross", bundle: .designSystem)
                    .resizable()
                    .frame(width: 14, height: 14)
            }
            .buttonStyle(.plain)
            .frame(width: 32, height: 32)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var list: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                row(for: item)
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func row(for item: T) -> some View {
        let isSelected = selection == item
        return Button {
            onSelect(item)
            isPresented = false
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                        .frame(width: 40, height: 40)
                    Image(item.imageName, bundle: .designSystem)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                }
                Text(AttributedStringHelper.makeLabelAttributedString(for: item.title))
                    .foregroundStyle(.primary)
                Spacer()
                selectionIndicator(isSelected: isSelected)
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func selectionIndicator(isSelected: Bool) -> some View {
        if isSelected {
            Circle()
                .fill(Color.green)
                .frame(width: 24, height: 24)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
        } else {
            Circle()
                .stroke(Color(.systemGray3), lineWidth: 2)
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    CurrencySelectorView(
        items: [
            CurrencyPresentation(title: "ARS", imageName: "ARS"),
            CurrencyPresentation(title: "EURc", imageName: "EUR"),
            CurrencyPresentation(title: "COP", imageName: "COP"),
            CurrencyPresentation(title: "MXN", imageName: "MXN"),
            CurrencyPresentation(title: "BRL", imageName: "BRL")
        ],
        selection: CurrencyPresentation(title: "MXN", imageName: "MXN"),
        isPresented: .constant(true),
        onSelect: { _ in }
    )
}

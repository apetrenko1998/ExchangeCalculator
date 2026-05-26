//
//  ExchangeCalculatorView.swift
//  ExchangeCalculator
//
//  Created by Anton Petrenko on 20/05/2026.
//

import SwiftUI
import UIKit
import DesignSystem
import Utilities
import UIComponents

enum Field { case base, quote }

@MainActor
public struct ExchangeCalculatorView: View {

    private struct Constants {
        static let titleKey = "exchangeCalculator"

        static let displayFormatter: NumberFormatter = {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.groupingSeparator = ","
            f.decimalSeparator = "."
            f.usesGroupingSeparator = true
            f.maximumFractionDigits = 2
            f.minimumFractionDigits = 0
            return f
        }()

        static let editFormatter: NumberFormatter = {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.usesGroupingSeparator = false
            f.decimalSeparator = "."
            f.maximumFractionDigits = 2
            f.minimumFractionDigits = 0
            return f
        }()
    }

    @State private var viewModel: ExchangeViewModel
    @State private var focusedField: Field?
    @State private var baseAmountText = "0"
    @State private var quoteAmountText = "0"

    init(viewModel: ExchangeViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            currencySection
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { focusedField = nil }
        .background(Colors.backgroundWhite.ignoresSafeArea())
        .loader(isLoading: viewModel.isLoading)
        .bottomSheet(isPresented: $viewModel.showCurrencySelector, content: {
            CurrencySelectorView(
                items: viewModel.currencyPresentations,
                selection: viewModel.quoteCurrencyPresentation,
                isPresented: $viewModel.showCurrencySelector,
                onSelect: { viewModel.selectQuoteCurrency($0) }
            )
        })
        .task {
            await viewModel.fetchInitialData()
        }
        .onChange(of: focusedField) { oldValue, newValue in
            switch oldValue {
            case .base:
                viewModel.didChangeBaseAmount(parseAmount(baseAmountText))
                baseAmountText = displayAmount(viewModel.baseCurrencyAmount)
            case .quote:
                viewModel.didChangeQuoteAmount(parseAmount(quoteAmountText))
                quoteAmountText = displayAmount(viewModel.quoteCurrencyAmount)
            case nil:
                break
            }
            switch newValue {
            case .base:
                baseAmountText = editAmount(viewModel.baseCurrencyAmount)
            case .quote:
                quoteAmountText = editAmount(viewModel.quoteCurrencyAmount)
            case nil:
                break
            }
        }
        .onChange(of: viewModel.baseCurrencyAmount) { _, newValue in
            guard focusedField != .base else { return }
            baseAmountText = displayAmount(newValue)
        }
        .onChange(of: viewModel.quoteCurrencyAmount) { _, newValue in
            guard focusedField != .quote else { return }
            quoteAmountText = displayAmount(newValue)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleAttributedString)
            Text(rateAttributedString)
        }
        .padding(.horizontal)
        .padding(.vertical, 24)
    }

    private var titleAttributedString: AttributedString {
        AttributedStringHelper.makeTitleAttributedString(for: Constants.titleKey)
    }

    private var rateAttributedString: AttributedString {
        AttributedStringHelper.makeLabelAttributedString(
            for: viewModel.exchangeRateLabel,
            foregroundColor: .systemGreen
        )
    }

    private var baseLabelAttributedString: AttributedString {
        AttributedStringHelper.makeLabelAttributedString(for: viewModel.baseCurrencyPresentation.title)
    }

    private var quoteLabelAttributedString: AttributedString {
        AttributedStringHelper.makeLabelAttributedString(for: viewModel.quoteCurrencyPresentation.title)
    }

    private var currencySection: some View {
        ZStack {
            VStack(spacing: 16) {
                if viewModel.isSwapped {
                    quoteCurrencyCard
                    baseCurrencyCard
                } else {
                    baseCurrencyCard
                    quoteCurrencyCard
                }
            }
            swapButton
                .onTapGesture {
                    withAnimation(.spring()) {
                        viewModel.swap()
                    }
                }
        }
        .padding(.horizontal)
    }

    private var baseCurrencyCard: some View {
        HStack {
            HStack(spacing: 8) {
                Image(viewModel.baseCurrencyPresentation.imageName, bundle: .designSystem)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
                Text(baseLabelAttributedString)
            }
            Spacer()
            amountField(text: $baseAmountText, field: .base)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 23)
        .background(Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var quoteCurrencyCard: some View {
        HStack {
            Button {
                viewModel.showCurrencySelector = true
            } label: {
                HStack(spacing: 8) {
                    Image(viewModel.quoteCurrencyPresentation.imageName, bundle: .designSystem)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .clipShape(Circle())
                    Text(quoteLabelAttributedString)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            Spacer()
            amountField(text: $quoteAmountText, field: .quote)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 23)
        .background(Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // Invisible Text drives the width so $ stays flush against the number.
    // The whole HStack is only as wide as its content, letting Spacer trail it.
    private func amountField(text: Binding<String>, field: Field) -> some View {
        HStack(spacing: 0) {
            Text("$")
                .font(.system(size: 16, weight: .bold))
                .tracking(0.02 * 16)
            Text(text.wrappedValue.isEmpty ? "0" : text.wrappedValue)
                .font(.system(size: 16, weight: .bold))
                .tracking(0.02 * 16)
                .opacity(0)
                .frame(minWidth: 10, maxWidth: 140)
                .overlay {
                    DecimalTextField(
                        text: text,
                        focusedField: $focusedField,
                        field: field,
                        font: .systemFont(ofSize: 16, weight: .bold)
                    )
                }
        }
        .fixedSize()
    }

    private var swapButton: some View {
        Circle()
            .fill(.green)
            .frame(width: 24, height: 24)
            .overlay {
                Image(systemName: "arrow.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(8)
            .background(
                Circle()
                    .fill(Color(.systemGroupedBackground))
            )
    }

    private func parseAmount(_ text: String) -> Decimal {
        let clean = text.filter { $0.isNumber || $0 == "." }
        guard !clean.isEmpty else { return 0 }
        let number = NSDecimalNumber(string: clean, locale: Locale(identifier: "en_US_POSIX"))
        return number == .notANumber ? 0 : number.decimalValue
    }

    private func displayAmount(_ amount: Decimal) -> String {
        Constants.displayFormatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    private func editAmount(_ amount: Decimal) -> String {
        guard amount != 0 else { return "" }
        return Constants.editFormatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

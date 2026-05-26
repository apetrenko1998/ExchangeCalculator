import Foundation

@MainActor
@Observable
final class ExchangeViewModel {
    
    var baseCurrencyAmount: Decimal = 0.0
    var quoteCurrencyAmount: Decimal = 0.0
    
    let baseCurrency: Currency = .usdc
    var quoteCurrency: Currency = .mxn {
        didSet {
            calculateExchangeRateLabel()
            guard editingField == nil, let (rate, inverted) = currentRate() else { return }
            quoteCurrencyAmount = inverted
                ? currencyConversionUseCase.calculateBaseAmount(quoteAmount: baseCurrencyAmount, rate: rate)
                : currencyConversionUseCase.calculateQuoteAmount(baseAmount: baseCurrencyAmount, rate: rate)
        }
    }
    
    var showCurrencySelector = false
    var isLoading: Bool = false
    var isSwapped = false
    
    var exchangeRateLabel: String = ""

    var baseCurrencyPresentation: CurrencyPresentation {
        currencyPresentationMapper.presentation(for: baseCurrency)
    }

    var quoteCurrencyPresentation: CurrencyPresentation {
        currencyPresentationMapper.presentation(for: quoteCurrency)
    }

    var currencyPresentations: [CurrencyPresentation] {
        currencies.map { currencyPresentationMapper.presentation(for: $0) }
    }

    private(set) var currencies: [Currency] = []
    private(set) var exchangeRates: [ExchangeRate] = []
    @ObservationIgnored
    private var editingField: Field?
    @ObservationIgnored
    private let currenciesUseCase: AvailableCurrenciesUseCaseInterface
    @ObservationIgnored
    private let exchangeRatesUseCase: ExchangeRatesUseCaseInterface
    @ObservationIgnored
    private let currencyConversionUseCase: CurrencyConversionUseCaseInterface
    @ObservationIgnored
    private let currencyPresentationMapper: CurrencyPresentationMapping
    
    init(
        currenciesUseCase: AvailableCurrenciesUseCaseInterface,
        exchangeRatesUseCase: ExchangeRatesUseCaseInterface,
        currencyConversionUseCase: CurrencyConversionUseCaseInterface,
        currencyPresentationMapper: CurrencyPresentationMapping
    ) {
        self.currenciesUseCase = currenciesUseCase
        self.exchangeRatesUseCase = exchangeRatesUseCase
        self.currencyConversionUseCase = currencyConversionUseCase
        self.currencyPresentationMapper = currencyPresentationMapper
    }
    
    nonisolated func fetchInitialData() async {
        do {
            await MainActor.run { [weak self] in self?.isLoading = true }
            let currencies = try await currenciesUseCase.fetch()
            await MainActor.run { [weak self] in self?.currencies = currencies }
            let exchangeRates = try await exchangeRatesUseCase.fetch(for: currencies)
            await MainActor.run { [weak self] in self?.exchangeRates = exchangeRates }
            await MainActor.run { [weak self] in
                self?.calculateExchangeRateLabel()
                self?.isLoading = false
            }
        } catch {
            debugPrint("Error while fetching initial data: " + String(describing: error))
            await MainActor.run { [weak self] in self?.isLoading = false }
        }
    }
    
    func didChangeBaseAmount(_ amount: Decimal) {
        guard editingField != .quote else { return }
        editingField = .base
        baseCurrencyAmount = amount
        if let (rate, inverted) = currentRate() {
            quoteCurrencyAmount = inverted
                ? currencyConversionUseCase.calculateBaseAmount(quoteAmount: amount, rate: rate)
                : currencyConversionUseCase.calculateQuoteAmount(baseAmount: amount, rate: rate)
        }
        editingField = nil
    }

    func didChangeQuoteAmount(_ amount: Decimal) {
        guard editingField != .base else { return }
        editingField = .quote
        quoteCurrencyAmount = amount
        if let (rate, inverted) = currentRate() {
            baseCurrencyAmount = inverted
                ? currencyConversionUseCase.calculateQuoteAmount(baseAmount: amount, rate: rate)
                : currencyConversionUseCase.calculateBaseAmount(quoteAmount: amount, rate: rate)
        }
        editingField = nil
    }
    
    func swap() {
        isSwapped.toggle()
        calculateExchangeRateLabel()
    }

    func selectQuoteCurrency(_ presentation: CurrencyPresentation) {
        guard let currency = currencies.first(where: {
            currencyPresentationMapper.presentation(for: $0) == presentation
        }) else { return }
        quoteCurrency = currency
    }
    
    private func currentRate() -> (rate: ExchangeRate, inverted: Bool)? {
        if let rate = exchangeRates.first(where: { $0.book.base == baseCurrency && $0.book.quote == quoteCurrency }) {
            return (rate, false)
        }
        if let rate = exchangeRates.first(where: { $0.book.base == quoteCurrency && $0.book.quote == baseCurrency }) {
            return (rate, true)
        }
        return nil
    }

    private func calculateExchangeRateLabel() {
        guard let (rate, _) = currentRate(), rate.bid != 0 else { return }
        let baseTitle = currencyPresentationMapper.presentation(for: baseCurrency).title
        let quoteTitle = currencyPresentationMapper.presentation(for: quoteCurrency).title
        if isSwapped {
            exchangeRateLabel = "1 \(quoteTitle) = \(1 / rate.bid) \(baseTitle)"
        } else {
            exchangeRateLabel = "1 \(baseTitle) = \(rate.bid) \(quoteTitle)"
        }
    }
}

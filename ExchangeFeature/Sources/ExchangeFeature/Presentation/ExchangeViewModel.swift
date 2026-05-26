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
        }
    }
    
    var showCurrencySelector = false
    var isLoading: Bool = false
    
    @ObservationIgnored
    var exchangeRateLabel: String = ""
    
    @ObservationIgnored
    var baseCurrencyPresentation: CurrencyPresentation {
        currencyPresentationMapper.presentation(for: baseCurrency)
    }

    @ObservationIgnored
    var quoteCurrencyPresentation: CurrencyPresentation {
        currencyPresentationMapper.presentation(for: quoteCurrency)
    }

    @ObservationIgnored
    var currencyPresentations: [CurrencyPresentation] {
        currencies.map { currencyPresentationMapper.presentation(for: $0) }
    }
    
    @ObservationIgnored
    private(set) var currencies: [Currency] = []
    @ObservationIgnored
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

        guard let currentExchangeRate = exchangeRates.first(where: { $0.book.base == baseCurrency && $0.book.quote == quoteCurrency }) else { return }
        
        quoteCurrencyAmount = currencyConversionUseCase.calculateQuoteAmount(
            baseAmount: amount,
            rate: currentExchangeRate
        )

        editingField = nil
    }

    func didChangeQuoteAmount(_ amount: Decimal) {
        guard editingField != .base else { return }

        editingField = .quote
        quoteCurrencyAmount = amount

        guard let currentExchangeRate = exchangeRates.first(where: { $0.book.base == baseCurrency && $0.book.quote == quoteCurrency }) else { return }
        
        baseCurrencyAmount = currencyConversionUseCase.calculateBaseAmount(
            quoteAmount: amount,
            rate: currentExchangeRate
        )

        editingField = nil
    }
    
    func selectQuoteCurrency(_ presentation: CurrencyPresentation) {
        guard let currency = currencies.first(where: {
            currencyPresentationMapper.presentation(for: $0) == presentation
        }) else { return }
        quoteCurrency = currency
    }
    
    private func calculateExchangeRateLabel() {
        guard let currentExchangeRate = exchangeRates.first(where: { $0.book.base == baseCurrency && $0.book.quote == quoteCurrency }) else { return }
        exchangeRateLabel = "1 USDc = \(currentExchangeRate.bid) \(quoteCurrency.rawValue.uppercased())"
    }
}

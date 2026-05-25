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

//// MARK: - State
//
//var usdcText: String = ""
//var currencyText: String = ""
//var selectedCurrency: Currency = Currency.all[0]
//var availableCurrencies: [Currency] = Currency.all
//var isSwapped: Bool = false
//var isLoadingRates: Bool = false
//var ratesUnavailable: Bool = false
//
//var rateDisplayText: String {
//    guard let rate = currentRate else {
//        if isLoadingRates { return "Loading rates..." }
//        return ratesUnavailable ? "Rate unavailable" : ""
//    }
//    let formatted = Self.rateFormatter.string(from: rate.bidRate as NSDecimalNumber) ?? rate.bidRate.description
//    return "1 USDc = \(formatted) \(selectedCurrency.id)"
//}
//
//// MARK: - Private
//
//private var rates: [String: ExchangeRate] = [:]
//private let repository: any ExchangeRatesRepository
//
//// MARK: - Init
//
//init(repository: any ExchangeRatesRepository) {
//    self.repository = repository
//}
//
//// MARK: - Public Actions
//
//func onAppear() async {
//    await fetchAvailableCurrencies()
//    await fetchRates()
//}
//
//func computeCurrencyFromUSDC() {
//    guard let usdc = parseDecimal(from: usdcText) else {
//        if usdcText.isEmpty { currencyText = "" }
//        return
//    }
//    guard let rate = currentRate else { return }
//    currencyText = usdc == 0 ? "0" : format(usdc * rate.bidRate)
//}
//
//func computeUSDCFromCurrency() {
//    guard let amount = parseDecimal(from: currencyText) else {
//        if currencyText.isEmpty { usdcText = "" }
//        return
//    }
//    guard let rate = currentRate, rate.bidRate > 0 else { return }
//    usdcText = amount == 0 ? "0" : format(amount / rate.bidRate)
//}
//
//func selectCurrency(_ currency: Currency) {
//    selectedCurrency = currency
//    computeCurrencyFromUSDC()
//}
//
//func swap() {
//    isSwapped.toggle()
//}
//
//// MARK: - Private
//
//private var currentRate: ExchangeRate? {
//    rates[selectedCurrency.id]
//}
//
//private func fetchRates() async {
//    isLoadingRates = true
//    ratesUnavailable = false
//    defer { isLoadingRates = false }
//
//    do {
//        let fetched = try await repository.fetchRates(for: availableCurrencies)
//        rates = Dictionary(uniqueKeysWithValues: fetched.map { ($0.currency.id, $0) })
//        computeCurrencyFromUSDC()
//    } catch {
//        ratesUnavailable = true
//    }
//}
//
//private func fetchAvailableCurrencies() async {
//    do {
//        let currencies = try await repository.fetchAvailableCurrencies()
//        if !currencies.isEmpty {
//            availableCurrencies = currencies
//            if !currencies.contains(selectedCurrency) {
//                selectedCurrency = currencies[0]
//            }
//        }
//    } catch {
//        // silently fall back to Currency.all (already the default)
//    }
//}
//
//private func parseDecimal(from text: String) -> Decimal? {
//    let cleaned = text.filter { $0.isNumber || $0 == "." }
//    return cleaned.isEmpty ? nil : Decimal(string: cleaned)
//}
//
//private func format(_ value: Decimal) -> String {
//    Self.amountFormatter.string(from: value as NSDecimalNumber) ?? value.description
//}
//
//private static let amountFormatter: NumberFormatter = {
//    let f = NumberFormatter()
//    f.maximumFractionDigits = 6
//    f.minimumFractionDigits = 2
//    f.usesGroupingSeparator = false
//    return f
//}()
//
//private static let rateFormatter: NumberFormatter = {
//    let f = NumberFormatter()
//    f.numberStyle = .decimal
//    f.maximumFractionDigits = 4
//    f.minimumFractionDigits = 4
//    f.usesGroupingSeparator = true
//    return f
//}()

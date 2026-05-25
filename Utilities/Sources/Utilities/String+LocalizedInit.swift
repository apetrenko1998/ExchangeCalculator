import Foundation

public extension String {
    init(mainBundleLocalizedValue: String.LocalizationValue) {
        self = String(localized: mainBundleLocalizedValue, bundle: .main)
    }
}

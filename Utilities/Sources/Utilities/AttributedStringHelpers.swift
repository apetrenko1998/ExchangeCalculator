import Foundation
import UIKit

public struct AttributedStringHelper {
    
    public static func makeLabelAttributedString(for stringKey: String, foregroundColor: UIColor = .label) -> AttributedString {
        let fontSize: CGFloat = 16
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 20
        paragraphStyle.maximumLineHeight = 20

        let attributed = NSAttributedString(
            string: String(mainBundleLocalizedValue: String.LocalizationValue(stringKey)),
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
                .kern: 0.02 * fontSize,
                .foregroundColor: foregroundColor
            ]
        )
        return AttributedString(attributed)
    }
    
    public static func makeTitleAttributedString(for stringKey: String) -> AttributedString {
        let fontSize: CGFloat = 30
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 33
        paragraphStyle.maximumLineHeight = 33

        let attributedTitle = NSAttributedString(
            string: String(mainBundleLocalizedValue: String.LocalizationValue(stringKey)),
            attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
            .kern: -0.02 * fontSize
        ])

        return AttributedString(attributedTitle)
    }
    
    public static func makeSubTitleAttributedString(for stringKey: String) -> AttributedString {
        let fontSize: CGFloat = 24
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 26
        paragraphStyle.maximumLineHeight = 26

        let attributedTitle = NSAttributedString(
            string: String(mainBundleLocalizedValue: String.LocalizationValue(stringKey)),
            attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            .kern: -0.02 * fontSize
        ])

        return AttributedString(attributedTitle)
    }
}

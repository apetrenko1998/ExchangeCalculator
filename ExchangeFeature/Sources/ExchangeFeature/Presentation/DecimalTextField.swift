import UIKit
import SwiftUI

// MARK: - Custom keyboard

private final class DecimalPadInputView: UIInputView {

    var onKey: ((String) -> Void)?
    var onDelete: (() -> Void)?

    private static let keyFont = UIFont.systemFont(ofSize: 25, weight: .regular)
    private static let subFont = UIFont.systemFont(ofSize: 10, weight: .bold)

    private static let subLabels: [String: String] = [
        "2": "ABC", "3": "DEF", "4": "GHI", "5": "JKL",
        "6": "MNO", "7": "PQRS", "8": "TUV", "9": "WXYZ"
    ]

    private static let layout: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor.systemGray3
        allowsSelfSizing = true

        let outerStack = UIStackView()
        outerStack.axis = .vertical
        outerStack.distribution = .fillEqually
        outerStack.spacing = 8
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerStack)

        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -58)
        ])

        for row in Self.layout {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 8

            for symbol in row {
                rowStack.addArrangedSubview(makeKey(symbol))
            }
            outerStack.addArrangedSubview(rowStack)
        }
    }

    private func makeKey(_ symbol: String) -> UIButton {
        let isDelete = symbol == "⌫"

        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 0

        if isDelete {
            button.backgroundColor = UIColor.systemGray3
            let img = UIImage(systemName: "delete.left")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
            button.setImage(img, for: .normal)
            button.tintColor = UIColor.label
            button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        } else {
            button.backgroundColor = UIColor.systemBackground
            button.contentVerticalAlignment = .center
            let title = NSMutableAttributedString(
                string: symbol,
                attributes: [
                    .font: Self.keyFont,
                    .foregroundColor: UIColor.label
                ]
            )
            if let sub = Self.subLabels[symbol] {
                title.append(NSAttributedString(
                    string: "\n" + sub,
                    attributes: [
                        .font: Self.subFont,
                        .foregroundColor: UIColor.label,
                        .kern: 2
                    ]
                ))
            }
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.setAttributedTitle(title, for: .normal)
            button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        }

        return button
    }

    @objc private func keyTapped(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        let symbol = String(title.prefix(1))
        onKey?(symbol)
    }

    @objc private func deleteTapped() {
        onDelete?()
    }
}

// MARK: - UIViewRepresentable

struct DecimalTextField: UIViewRepresentable {

    @Binding var text: String
    @Binding var focusedField: Field?
    let field: Field
    var font: UIFont = .systemFont(ofSize: 16, weight: .bold)

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.delegate = context.coordinator
        tf.font = font
        tf.textAlignment = .left
        tf.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        tf.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        tf.tintColor = .black

        let safeAreaBottom = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: \.isKeyWindow)?.safeAreaInsets.bottom ?? 34
        let keyboard = DecimalPadInputView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 291 + safeAreaBottom),
            inputViewStyle: .keyboard
        )
        keyboard.onKey = { symbol in
            context.coordinator.handleKey(symbol)
        }
        keyboard.onDelete = {
            context.coordinator.handleDelete()
        }
        tf.inputView = keyboard

        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        let shouldFocus = focusedField == field
        let isFocused = uiView.isFirstResponder

        if shouldFocus && !isFocused {
            DispatchQueue.main.async { uiView.becomeFirstResponder() }
        } else if !shouldFocus && isFocused {
            DispatchQueue.main.async { uiView.resignFirstResponder() }
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UITextFieldDelegate {

        var parent: DecimalTextField
        private var hasDecimal = false

        init(_ parent: DecimalTextField) {
            self.parent = parent
        }

        func handleKey(_ symbol: String) {
            let current = parent.text
            if symbol == "." {
                guard !hasDecimal else { return }
                hasDecimal = true
                parent.text = current.isEmpty ? "0." : current + "."
            } else if hasDecimal {
                let decimalPart = current.components(separatedBy: ".").last ?? ""
                guard decimalPart.count < 2 else { return }
                parent.text = current + symbol
            } else {
                let digitCount = current.filter { $0.isNumber }.count
                guard digitCount < 10 else { return }
                parent.text = current == "0" ? symbol : current + symbol
            }
        }

        func handleDelete() {
            var current = parent.text
            if current.last == "." { hasDecimal = false }
            if !current.isEmpty { current.removeLast() }
            parent.text = current
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            hasDecimal = parent.text.contains(".")
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.parent.focusedField != self.parent.field {
                    self.parent.focusedField = self.parent.field
                }
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.parent.focusedField == self.parent.field {
                    self.parent.focusedField = nil
                }
            }
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty {
                handleDelete()
                return false
            }
            // Handle hardware keyboard, paste, dictation: filter to digits and decimal only
            let valid = string.filter { $0.isNumber || $0 == "." }
            for char in valid {
                handleKey(String(char))
            }
            return false
        }
    }
}

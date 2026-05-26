//
//  AnyRoutable.swift
//  ExchangeCalculator
//
//  Created by Антон Петренко on 23/05/2026.
//

import SwiftUI
import Utilities

struct AnyRoutable: Routable {

    private let base: any Routable
    private let identifier: AnyHashable

    init<T: Routable>(_ routable: T) {
        self.base = routable
        self.identifier = AnyHashable(routable)
    }

    func makeView() -> AnyView {
        base.makeView()
    }

    func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }

    static func == (lhs: AnyRoutable, rhs: AnyRoutable) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

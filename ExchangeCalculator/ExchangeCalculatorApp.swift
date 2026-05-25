//
//  ExchangeCalculatorApp.swift
//  ExchangeCalculator
//
//  Created by Антон Петренко on 20/05/2026.
//

import SwiftUI
import Utilities
import Networking
import ExchangeFeature

@main
struct ExchangeCalculatorApp: App {
    
    private var diContainer: DependencyContainer
    
    init() {
        self.diContainer = DependencyContainer()
        diContainer.registerUtilitiesDependencies()
        diContainer.registerNetworkingDependencies()
        diContainer.registerExchangeFeatureDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            CustomNavigationView(
                appRouter: .init(
                    navigationPath: .init(),
                    resolver: diContainer
                )
            )
        }
    }
}

//
//  CustomNavigationView.swift
//  ExchangeCalculator
//
//  Created by Антон Петренко on 23/05/2026.
//

import SwiftUI
import Utilities

struct CustomNavigationView: View {
    
    @StateObject var appRouter: AppRouter
    
    var body: some View {
        NavigationStack(path: $appRouter.navigationPath) {
            appRouter.initialView
                .navigationDestination(for: AnyRoutable.self) { router in
                    router.makeView()
                }
        }
    }
}

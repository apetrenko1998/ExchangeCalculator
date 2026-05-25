//
//  CurrencyPresentation.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 24/05/2026.
//


public struct CurrencyPresentation: Identifiable, Hashable, Sendable, SelectableItem {
    public var id: String { title }
    public let title: String
    public let imageName: String
}

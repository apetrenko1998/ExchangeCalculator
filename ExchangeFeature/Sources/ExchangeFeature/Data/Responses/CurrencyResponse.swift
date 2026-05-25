//
//  CurrencyResponse.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 24/05/2026.
//

public enum CurrencyResponse: String, Decodable, Equatable, Sendable {
    case usdc = "usdc"
    case mxn = "mxn"
    case ars = "ars"
    case cop = "cop"
    case brl = "brl"

    public init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        guard let value = CurrencyResponse(rawValue: raw.lowercased()) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unknown currency: \(raw)")
            )
        }
        self = value
    }

    public func toDomain() -> Currency {
        switch self {
        case .usdc: return .usdc
        case .mxn: return .mxn
        case .ars: return .ars
        case .cop: return .cop
        case .brl: return .brl
        }
    }
}

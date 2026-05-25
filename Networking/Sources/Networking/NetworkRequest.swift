//
//  NetworkRequest.swift
//  Networking
//
//  Created by Антон Петренко on 23/05/2026.
//

import Foundation

public protocol NetworkRequest: Sendable {
    associatedtype ResponseDataType: Sendable

    func create() throws -> URLRequest
    func parse(data: Data) throws -> ResponseDataType
}

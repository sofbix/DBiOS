//
//  EnityData.swift
//
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation

// For reserved informations
public struct EnityData: Hashable {
    public static func == (lhs: EnityData, rhs: EnityData) -> Bool {
        return true
    }

    public var hashValue: Int { 0 }

    public let data: Any?

    public init(data: Any?) {
        self.data = data
    }
}

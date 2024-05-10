//
//  Todo.swift
//
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation

public struct Todo: Identifiable, Hashable {
    public var id: UUID
    public var name: String
    public var date: String
    public var comments: String?
    public var groupId: UUID?
    public var count: Int

    // reserved
    public var data: EnityData?

    public init(id: UUID, name: String, date: Date?, comments: String? = nil, groupId: UUID? = nil, count: Int, data: EnityData? = nil) {
        var stringDate = ""
        if let rawDate = date {
            stringDate = Self.dateFormatter.string(from: rawDate)
        }

        self.id = id
        self.name = name
        self.date = stringDate
        self.comments = comments
        self.groupId = groupId
        self.count = count
        self.data = data
    }

    static let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .short
        result.timeStyle = .medium
        return result
    }()
}

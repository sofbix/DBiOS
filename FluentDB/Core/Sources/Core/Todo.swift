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

    public init(id: UUID, name: String, date: String, comments: String? = nil, groupId: UUID? = nil, count: Int, data: EnityData? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.comments = comments
        self.groupId = groupId
        self.count = count
        self.data = data
    }
}

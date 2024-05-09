//
//  Todo.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 08.05.2024.
//

import Foundation
import SwiftData

struct Todo: Identifiable, Hashable {
    var id: UUID
    var name: String
    var date: String
    var comments: String?
    var groupId: UUID?
    var count: Int
}

@Model
final class TodoEntity {
    
    @Attribute(.unique)
    var id: UUID?

    var name: String

    var comments: String?

    var group: TodoGroupEntity?

    var date: Date?

    @Transient
    var count: Int = 0

    init(id: UUID? = nil, name: String, comments: String? = nil, count: Int = 0) {
        self.id = id
        self.name = name
        self.comments = comments
        self.count = count
    }

    var dao: Todo {
        var date = ""
        if let rawDate = self.date {
            date = Self.dateFormatter.string(from: rawDate)
        }
        return Todo(id: self.id ?? UUID(), name: self.name, date: date, comments: self.comments, groupId: self.group?.id, count: self.count)
    }

    static let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .short
        result.timeStyle = .medium
        return result
    }()
}

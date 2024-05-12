//
//  Todo.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 08.05.2024.
//

import Foundation
import SwiftData
import Core

@Model
final class TodoEntity {
    
    @Attribute(.unique)
    var id: UUID?

    @Attribute(.spotlight)
    var name: String

    var comments: String?

    @Attribute(.spotlight)
    var group: TodoGroupEntity?

    @Attribute(.spotlight)
    var date: Date?

    @Attribute(.spotlight)
    var priority: Int?

    @Transient
    var count: Int = 0

    init(id: UUID? = nil, name: String, comments: String? = nil, date: Date = Date(), priority: Int? = nil, count: Int = 0) {
        self.id = id
        self.name = name
        self.comments = comments
        self.count = count
        self.date = date
        self.priority = priority
    }

    var dao: Todo {
        let persistentID: PersistentIdentifier = self.id
        return Todo(id: self.id ?? UUID(), name: self.name, date: date, comments: self.comments, groupId: self.group?.id, count: self.count, data: EnityData(data: persistentID))
    }
}

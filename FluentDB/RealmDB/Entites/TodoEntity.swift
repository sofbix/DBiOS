//
//  TodoEntity.swift
//  RealmDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation
import RealmSwift
import Core

final class TodoEntity : Object {

    @Persisted (primaryKey: true)
    var id: UUID

    @Persisted(indexed: true)
    var name: String

    @Persisted 
    var comments: String?

    @Persisted(indexed: true)
    var date: Date?

    @Persisted(indexed: true)
    var priority: Int?

    @Persisted
    var group: TodoGroupEntity?

    var count: Int = 0

    convenience init(id: UUID = UUID(), name: String, date: Date? = Date(), priority: Int? = nil) {
        self.init()
        self.id = id
        self.name = name
        self.date = date
        self.priority = priority
    }

    var dao: Todo {
        return Todo(id: self.id, name: self.name, date: date, comments: self.comments, groupId: self.group?.id, count: self.count)
    }
}


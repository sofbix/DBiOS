//
//  TodoEntity.swift
//  CoreStoreDB
//
//  Created by Sergey Balalaev on 29.05.2024.
//

import Foundation
import CoreStore
import Core

final class TodoEntity : CoreStoreObject {

    @Field.Stored("id", dynamicInitialValue: { UUID() })
    var id: UUID

    @Field.Stored("name", dynamicInitialValue: { "" })
    var name: String

    @Field.Stored("comments")
    var comments: String?

    @Field.Stored("date")
    var date: Date?

    @Field.Stored("priority")
    var priority: Int?

    @Field.Relationship("group")
    var group: TodoGroupEntity?

    var count: Int = 0

    var dao: Todo {
        return Todo(id: self.id, name: self.name, date: date, comments: self.comments, groupId: self.group?.id, count: self.count)
    }
}


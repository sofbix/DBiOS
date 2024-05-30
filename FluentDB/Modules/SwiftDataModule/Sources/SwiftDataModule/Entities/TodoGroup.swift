//
//  TodoGroup.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 08.05.2024.
//

import Foundation
import SwiftData

@Model
final class TodoGroupEntity {

    @Attribute(.unique)
    var id: UUID?

    var name: String

    @Relationship(deleteRule: .cascade, inverse: \TodoEntity.group)
    var todos: [TodoEntity]

    init(id: UUID? = nil, name: String, todos: [TodoEntity] = []) {
        self.id = id
        self.name = name
        self.todos = todos
    }
}

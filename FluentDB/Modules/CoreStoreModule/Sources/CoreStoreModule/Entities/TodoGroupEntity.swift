//
//  TodoGroupEntity.swift
//  CoreStoreDB
//
//  Created by Sergey Balalaev on 29.05.2024.
//

import Foundation
import CoreStore

final class TodoGroupEntity : CoreStoreObject {

    @Field.Stored("id", dynamicInitialValue: { UUID() })
    var id: UUID

    @Field.Stored("name", dynamicInitialValue: { "" })
    var name: String

    @Field.Relationship("todos", inverse: \TodoEntity.$group)
    var todos: Set<TodoEntity>

}

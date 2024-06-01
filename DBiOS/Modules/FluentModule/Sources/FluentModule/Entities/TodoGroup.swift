//
//  TodoGroup.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 04.03.2024.
//

import Foundation
import FluentKit

final class TodoGroupEntity : Model {

    static var schema: String = "TodoGroup"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Children(for: \.$group)
    var todos: [TodoEntity]

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }

    init() {
        id = UUID.generateRandom()
        name = ""
    }
}


struct CreateTodoGroupEntity: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema(TodoGroupEntity.schema)
            .ignoreExisting()
            .id()
            .field("name", .string, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema(TodoGroupEntity.schema).delete()
    }
}

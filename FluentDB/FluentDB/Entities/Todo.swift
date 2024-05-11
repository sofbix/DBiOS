//
//  Todo.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 08.02.2024.
//

import Foundation
import FluentKit
import Core
import SQLKit

final class TodoEntity : Model {

    static var schema: String = "Todo"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "comments")
    var comments: String?

    @OptionalField(key: "date")
    var date: Date?

    @OptionalParent(key: "group_id")
    var group: TodoGroupEntity?

    var count: Int = 0

    init(id: UUID? = nil, name: String, date: Date? = Date()) {
        self.id = id
        self.name = name
        self.date = date
    }

    init() {
        id = UUID.generateRandom()
        name = ""
        date = Date()
    }

    var dao: Todo {
        return Todo(id: self.id ?? UUID(), name: self.name, date: date, comments: self.comments, groupId: self.$group.id, count: self.count)
    }
}


struct CreateTodoEntity: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema(TodoEntity.schema)
            .ignoreExisting()
            .id()
            .field("name", .string, .required)
            .field("comments", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema(TodoEntity.schema).delete()
    }
}

struct DateTodoEntity: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema(TodoEntity.schema)
            .ignoreExisting()
            .field("date", .datetime)
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema(TodoEntity.schema)
            .deleteField("date")
            .update()
    }
}

struct GroupTodoEntity: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema(TodoEntity.schema)
            .ignoreExisting()
            .field("group_id", .uuid, .references("TodoGroup", "id", onDelete: .cascade))
            //.foreignKey("group_id", references: "TodoGroup", "id", onDelete: .cascade)
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema(TodoEntity.schema)
            .deleteField("group_id")
            .update()
    }
}

struct CreateTodoNameIndex: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .create(index: "todo_name_index")
            .on(TodoEntity.schema)
            .column("name")
            .run()
    }

    func revert(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .drop(index: "todo_name_index")
            .run()
    }

}

struct CreateTodoDateIndex: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .create(index: "todo_date_index")
            .on(TodoEntity.schema)
            .column("date")
            .run()
    }

    func revert(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .drop(index: "todo_date_index")
            .run()
    }

}

struct CreateTodoGroupIndex: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .create(index: "todo_group_id_index")
            .on(TodoEntity.schema)
            .column("group_id")
            .run()
    }

    func revert(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .drop(index: "todo_group_id_index")
            .run()
    }

}

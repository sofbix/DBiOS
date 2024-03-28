//
//  Todo.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 08.02.2024.
//

import Foundation
import FluentKit

struct Todo: Identifiable, Hashable {
    var id: UUID
    var name: String
    var date: String
    var comments: String?
    var groupId: UUID?
    var count: Int
}

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
        var date = ""
        if let rawDate = self.date {
            date = Self.dateFormatter.string(from: rawDate)
        }
        return Todo(id: self.id ?? UUID(), name: self.name, date: date, comments: self.comments, groupId: self.$group.id, count: self.count)
    }

    static let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .short
        result.timeStyle = .medium
        return result
    }()
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

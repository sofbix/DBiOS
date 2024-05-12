//
//  FluentDatabaseQuery.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation
import FluentKit
import Core


struct FluentDatabaseQuery : DatabaseQueryProtocol {
    let databaseManager: DatabaseManager

    func getAllGroupsCount() async throws -> Int {
        try await databaseManager.db.query(TodoGroupEntity.self).count()
    }

    func getAllGroups() async throws -> [Group] {
        let groups = try await databaseManager.db.query(TodoGroupEntity.self)
            .sort(\.$name, .ascending)
            .all()
            .map{ item in
                Group(id: item.id ?? UUID(), name: item.name)
            }
        return groups
    }

    func getGroups(with searchText: String) async throws -> [TodoGroup] {
        let groups = try await databaseManager.db.query(TodoGroupEntity.self)
            .filter(\.$name ~~ searchText)
            .sort(\.$name, .ascending)
            .with(\.$todos)
            .all()
            .map{ item in
                TodoGroup(id: item.id ?? UUID(), name: item.name, todos: item.todos.map{$0.dao})
            }
        return groups
    }

    func addNewGroup(name: String) async throws {
        let group = TodoGroupEntity(id: nil, name: name)
        try await group.save(on: DatabaseManager.shared.db)
    }

    func removeAllGroups() async throws {
        try await databaseManager.db.query(TodoGroupEntity.self).delete()
    }

    func getAllTasksCount() async throws -> Int {
        try await databaseManager.db.query(TodoEntity.self).count()
    }

    func getTasksWithoutGroup() async throws -> [Todo] {
        let todos = try await TodoEntity.query(on: DatabaseManager.shared.db)
            .filter(\TodoEntity.$group.$id, .equal, .none)
            .all()
            .map { $0.dao }
        return todos
    }

    func getTasks(with searchText: String) async throws -> [Todo] {
        let tasks = try await databaseManager.db.query(TodoEntity.self)
            .filter(\.$name ~~ searchText)
            .sort(\.$name, .ascending)
            .all()
            .map { $0.dao }
        return tasks
    }

    func getTasks(startDate: Date, stopDate: Date) async throws -> [Todo] {
        let tasks = try await databaseManager.db.query(TodoEntity.self)
            .filter(\.$date > startDate)
            .filter(\.$date < stopDate)
            .sort(\.$date)
            .all()
            .map { $0.dao }
        return tasks
    }

    func getTasks(startPriority: Int, stopPriority: Int) async throws -> [Todo] {
        let tasks = try await databaseManager.db.query(TodoEntity.self)
            .filter(\.$priority >= startPriority)
            .filter(\.$priority <= stopPriority)
            .sort(\.$priority)
            .all()
            .map { $0.dao }
        return tasks
    }

    func addNewTodo(name: String, comments: String, date: Date, priority: Int?, selectedGroup: Group) async throws {
        let todo = TodoEntity(id: nil, name: name, date: date, priority: priority)
        todo.comments = comments
        todo.$group.id = selectedGroup.id
        try await todo.save(on: DatabaseManager.shared.db)
    }

    func updateTodo(_ editedTodo: Todo, name: String, comments: String, selectedGroup: Group) async throws {
        guard let todo = try await TodoEntity.find(editedTodo.id, on: DatabaseManager.shared.db).get() else {
            return
        }
        todo.name = name
        todo.comments = comments
        todo.$group.id = selectedGroup.id
        try await todo.save(on: DatabaseManager.shared.db)
    }

    func removeAllTodos() async throws {
        try await databaseManager.db.query(TodoEntity.self).delete()
    }
}

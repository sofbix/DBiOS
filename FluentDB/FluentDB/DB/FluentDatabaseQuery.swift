//
//  FluentDatabaseQuery.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation
import Fluent

protocol TodoProtocol: Identifiable, Hashable {
    var id: UUID {get}
    var name: String {get}
    var date: String {get}
    var comments: String? {get}
    var groupId: UUID? {get}
    var count: Int {get}
}

protocol TodoGroupProtocol: Identifiable, Hashable {
    associatedtype Todo: TodoProtocol
    var id: UUID? {get}
    var name: String {get}
    var todos: [Todo] {get}
}

protocol DatabaseQueryProtocol {

    func getAllGroups() async throws -> [Group]
    func getGroups(with searchText: String) async throws -> [TodoGroup]
    func addNewGroup(name: String) async throws


    func getTasksWithoutGroup() async throws -> [Todo]
    func addNewTodo(name: String, comments: String, selectedGroup: Group) async throws
    func updateTodo(_ editedTodo: Todo, name: String, comments: String, selectedGroup: Group) async throws
}

struct FluentDatabaseQuery : DatabaseQueryProtocol {
    let databaseManager: DatabaseManager

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

    func getTasksWithoutGroup() async throws -> [Todo] {
        let todos = try await TodoEntity.query(on: DatabaseManager.shared.db)
            .filter(\TodoEntity.$group.$id, .equal, .none)
            .all()
            .map { $0.dao }
        return todos
    }

    func addNewTodo(name: String, comments: String, selectedGroup: Group) async throws {
        let todo = TodoEntity(id: nil, name: name)
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
}

//
//  SwiftDataDatabaseQuery.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation
import SwiftData
import CoreModule

public struct SwiftDataDatabaseQuery : DatabaseQueryProtocol {

    let databaseManager: DatabaseManager

    public init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }

    public func getAllGroupsCount() async throws -> Int {
        let newContext = ModelContext(DatabaseManager.shared.container)
        return try newContext.fetchCount(FetchDescriptor<TodoGroupEntity>())
    }

    public func getAllGroups() async throws -> [Group] {
        let newContext = ModelContext(DatabaseManager.shared.container)
        let groupsPredicate = #Predicate<TodoGroupEntity>{ entity in
            true
        }
        let groupsDescriptor = FetchDescriptor<TodoGroupEntity>(
            predicate: groupsPredicate,
            sortBy: [SortDescriptor(\.name)]
        )
        let groups = try newContext
            .fetch(groupsDescriptor)
            .map { item in
                let persistentID: PersistentIdentifier = item.id
                return Group(id: item.id ?? UUID(), name: item.name, data: EnityData(data: persistentID))
            }
        return groups
    }

    public func getGroups(with searchText: String) async throws -> [TodoGroup] {
        let newContext = ModelContext(DatabaseManager.shared.container)
        let groupsPredicate = #Predicate<TodoGroupEntity>{ entity in
            entity.name.contains(searchText) || searchText.isEmpty
        }
        let groupsDescriptor = FetchDescriptor<TodoGroupEntity>(
            predicate: groupsPredicate,
            sortBy: [SortDescriptor(\.name)]
        )
        let groups = try newContext
            .fetch(groupsDescriptor)
            .map { item in
                TodoGroup(id: item.id ?? UUID(), name: item.name, todos: item.todos.map{$0.dao})
            }
        return groups
    }

    public func addNewGroup(name: String) async throws {
        let modelContext = ModelContext(DatabaseManager.shared.container)
        let group = TodoGroupEntity(id: nil, name: name)
        modelContext.insert(group)
        try modelContext.save()
    }

    public func removeAllGroups() async throws {
        let newContext = ModelContext(DatabaseManager.shared.container)
        try newContext.delete(model: TodoGroupEntity.self)
    }

    public func getAllTasksCount() async throws -> Int {
        let newContext = ModelContext(DatabaseManager.shared.container)
        return try newContext.fetchCount(FetchDescriptor<TodoEntity>())
    }

    public func getTasksWithoutGroup() async throws -> [Todo] {
        let newContext = ModelContext(DatabaseManager.shared.container)
        let todosPredicate = #Predicate<TodoEntity>{ entity in
            entity.group == nil
        }
        let todosDescriptor = FetchDescriptor<TodoEntity>(
            predicate: todosPredicate,
            sortBy: []
        )
        let todos = try newContext
            .fetch(todosDescriptor)
            .map { $0.dao }
        return todos
    }

    public func getTasks(with searchText: String) async throws -> [Todo] {
        let newContext = ModelContext(DatabaseManager.shared.container)
        let todosPredicate = searchText.isEmpty == false ?
        #Predicate<TodoEntity>{ entity in
            entity.name.contains(searchText)
        } 
        :
        #Predicate<TodoEntity>{_ in true }
        let todosDescriptor = FetchDescriptor<TodoEntity>(
            predicate: todosPredicate,
            sortBy: [SortDescriptor(\.name)]
        )
        let todos = try newContext
            .fetch(todosDescriptor)
            .map { $0.dao }
        return todos
    }

    public func getTasks(startDate: Date, stopDate: Date) async throws -> [Todo] {
        let newContext = ModelContext(DatabaseManager.shared.container)
        let todosPredicate = #Predicate<TodoEntity>{ entity in
            if let date = entity.date {
                return date > startDate && date < stopDate
            } else {
                return false
            }
        }
        let todosDescriptor = FetchDescriptor<TodoEntity>(
            predicate: todosPredicate,
            sortBy: [SortDescriptor(\.date)]
        )
        let todos = try newContext
            .fetch(todosDescriptor)
            .map { $0.dao }
        return todos
    }

    public func getTasks(startPriority: Int, stopPriority: Int) async throws -> [Todo] {
        let newContext = ModelContext(DatabaseManager.shared.container)
        let todosPredicate = #Predicate<TodoEntity>{ entity in
            if let priority = entity.priority {
                return priority >= startPriority && priority <= stopPriority
            } else {
                return false
            }
        }
        let todosDescriptor = FetchDescriptor<TodoEntity>(
            predicate: todosPredicate,
            sortBy: [SortDescriptor(\.priority)]
        )
        let todos = try newContext
            .fetch(todosDescriptor)
            .map { $0.dao }
        return todos
    }

    public func addNewTodo(name: String, comments: String, date: Date, priority: Int?, selectedGroup: Group) async throws {
        let modelContext = ModelContext(DatabaseManager.shared.container)
        let todo = TodoEntity(id: nil, name: name, date: date, priority: priority)
        todo.comments = comments
        todo.group = selectedGroupEntity(modelContext, selectedGroup: selectedGroup)
        modelContext.insert(todo)
        try modelContext.save()
    }

    public func updateTodo(_ editedTodo: Todo, name: String, comments: String, selectedGroup: Group) async throws {
        let newContext = ModelContext(DatabaseManager.shared.container)

        guard 
            let persistentID = editedTodo.data?.data as? PersistentIdentifier,
            let todo = newContext.model(for: persistentID) as? TodoEntity
        else {
            return
        }
        todo.name = name
        todo.comments = comments
        todo.group = selectedGroupEntity(newContext, selectedGroup: selectedGroup)
        try newContext.save()
    }

    private func selectedGroupEntity(_ context: ModelContext, selectedGroup: Group) -> TodoGroupEntity? {
        guard
            let persistentID = selectedGroup.data?.data as? PersistentIdentifier,
            let group = context.model(for: persistentID) as? TodoGroupEntity
        else {
            return nil
        }
        return group
    }

    public func removeAllTodos() async throws {
        let newContext = ModelContext(DatabaseManager.shared.container)
        try newContext.delete(model: TodoEntity.self)
    }

}

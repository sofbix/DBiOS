//
//  CoreStoreDatabaseQuery.swift
//  CoreStoreDB
//
//  Created by Sergey Balalaev on 29.05.2024.
//

import Foundation
import CoreStore
import Core


struct CoreStoreDatabaseQuery : DatabaseQueryProtocol {

    let databaseManager: DatabaseManager

    private func synchronous<T>(_ handler: (_ transaction: SynchronousDataTransaction) throws -> T) throws -> T {
        try databaseManager.dataStack.perform(
            synchronous: { transaction in
                try handler(transaction)
            },
            waitForAllObservers: true
        )
    }

    func getAllGroupsCount() async throws -> Int {
        try synchronous { dataStack in
            try dataStack.fetchCount( From<TodoGroupEntity>() )
        }
    }

    func getAllGroups() async throws -> [Group] {
        try synchronous { dataStack in
            try dataStack.fetchAll(
                From<TodoGroupEntity>()
                    .orderBy(.ascending(\.$name))
            ).map { item in
                Group(id: item.id, name: item.name)
            }
        }
    }

    func getGroups(with searchText: String) async throws -> [TodoGroup] {
        try synchronous { dataStack in
            try dataStack.fetchAll(
                searchText.isEmpty == true
                ?
                    From<TodoGroupEntity>()
                        .orderBy(.ascending(\.$name))
                :
                    From<TodoGroupEntity>()
                        .where(
                            format: "%K CONTAINS[cd] %@",
                            String(keyPath: \TodoGroupEntity.$name),
                            searchText
                        )
                        .orderBy(.ascending(\.$name))
            ).map { item in
                TodoGroup(id: item.id, name: item.name, todos: item.todos.map{$0.dao})
            }
        }
    }

    func addNewGroup(name: String) async throws {
        try synchronous { transaction in
            let group = transaction.create(Into<TodoGroupEntity>())
            group.name = name
        }
    }

    func removeAllGroups() async throws {
        _ = try databaseManager.dataStack.perform( synchronous: { transaction in
            try transaction.deleteAll(From<TodoGroupEntity>())
        }, waitForAllObservers: true)
    }

    func getAllTasksCount() async throws -> Int {
        try synchronous { dataStack in
            try dataStack.fetchCount( From<TodoEntity>() )
        }
    }

    func getTasksWithoutGroup() async throws -> [Todo] {
        try synchronous { dataStack in
            try dataStack.fetchAll(
                From<TodoEntity>()
                    .where(\.$group == nil)
            )
            .map { $0.dao }
        }
    }

    func getTasks(with searchText: String) async throws -> [Todo] {
        try synchronous { dataStack in
            try dataStack.fetchAll(
                searchText.isEmpty == true
                ?
                    From<TodoEntity>()
                        .orderBy(.ascending(\.$name))
                :
                    From<TodoEntity>()
                        .where(
                            format: "%K CONTAINS[cd] %@",
                            String(keyPath: \TodoEntity.$name),
                            searchText
                        )
                        .orderBy(.ascending(\.$name))
            ).map { $0.dao }
        }
    }

    func getTasks(startDate: Date, stopDate: Date) async throws -> [Todo] {
        try synchronous { dataStack in
            try dataStack.fetchAll(
                From<TodoEntity>()
                    .where(\.$date >= startDate && \.$date <= stopDate)
                    .orderBy(.ascending(\.$date))
            ).map { $0.dao }
        }
    }

    func getTasks(startPriority: Int, stopPriority: Int) async throws -> [Todo] {
        try synchronous { dataStack in
            try dataStack.fetchAll(
                From<TodoEntity>()
                .where(\.$priority >= startPriority && \.$priority <= stopPriority)
                .orderBy(.ascending(\.$priority))
            ).map { $0.dao }
        }
    }

    func addNewTodo(name: String, comments: String, date: Date, priority: Int?, selectedGroup: Group) async throws {
        try databaseManager.dataStack.perform( synchronous: { transaction in
            let todo = transaction.create(Into<TodoEntity>())
            todo.name = name
            todo.date = date
            todo.priority = priority
            todo.comments = comments
            todo.group = selectedGroupEntity(transaction, selectedGroup)
        }, waitForAllObservers: true)
    }

    func updateTodo(_ editedTodo: Todo, name: String, comments: String, selectedGroup: Group) async throws {
        try synchronous { dataStack in
            guard let todo = try dataStack.fetchOne(
                From<TodoEntity>()
                    .where(\.$id == editedTodo.id)
            ) else {
                return
            }
            todo.name = name
            todo.comments = comments
            todo.group = selectedGroupEntity(dataStack, selectedGroup)
        }
    }

    private func selectedGroupEntity(_ transaction: SynchronousDataTransaction, _ selectedGroup: Group) -> TodoGroupEntity? {
        guard let id = selectedGroup.id else {
            return nil
        }
        return try? transaction.fetchOne(
            From<TodoGroupEntity>()
                .where(\.$id == id)
        )
    }

    func removeAllTodos() async throws {
        _ = try databaseManager.dataStack.perform( synchronous: { transaction in
            try transaction.deleteAll(From<TodoEntity>())
        }, waitForAllObservers: true)
    }
}

//
//  RealmDatabaseQuery.swift
//  RealmDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation
import RealmSwift
import CoreModule


public struct RealmDatabaseQuery : DatabaseQueryProtocol {

    let databaseManager: DatabaseManager

    public init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }

    public func getAllGroupsCount() async throws -> Int {
        databaseManager.realm.objects(TodoGroupEntity.self).count
    }

    public func getAllGroups() async throws -> [Group] {
        return databaseManager.realm.objects(TodoGroupEntity.self)
            .sorted(by: \.name, ascending: true)
            .map { item in
                Group(id: item.id, name: item.name)
            }
    }

    public func getGroups(with searchText: String) async throws -> [TodoGroup] {
        var query = databaseManager.realm.objects(TodoGroupEntity.self)

        if !searchText.isEmpty {
            query = query
                .where {
                    $0.name.contains(searchText)
                }
        }

        return query
            .sorted(by: \.name, ascending: true)
            .map{ item in
                TodoGroup(id: item.id, name: item.name, todos: item.todos.map{$0.dao})
            }
    }

    public func addNewGroup(name: String) async throws {
        let group = TodoGroupEntity(name: name)
        try databaseManager.realm.write{
            databaseManager.realm.add(group)
        }
    }

    public func removeAllGroups() async throws {
        let realm = databaseManager.realm
        try realm.write{
            let objects = realm.objects(TodoGroupEntity.self)
            realm.delete(objects)
        }
    }

    public func getAllTasksCount() async throws -> Int {
        databaseManager.realm.objects(TodoEntity.self).count
    }

    public func getTasksWithoutGroup() async throws -> [Todo] {
        return databaseManager.realm.objects(TodoEntity.self)
            .where {
                $0.group == nil
            }
            .map { $0.dao }
    }

    public func getTasks(with searchText: String) async throws -> [Todo] {
        var query = databaseManager.realm.objects(TodoEntity.self)

        if !searchText.isEmpty {
            query = query
                .where {
                    $0.name.contains(searchText)
                }
        }

        return query
            .sorted(by: \.name, ascending: true)
            .map { $0.dao }
    }

    public func getTasks(startDate: Date, stopDate: Date) async throws -> [Todo] {
        let query = databaseManager.realm.objects(TodoEntity.self)
            .where {
                $0.date > startDate && $0.date < stopDate
            }

        return query
            .sorted(by: \.date)
            .map { $0.dao }
    }

    public func getTasks(startPriority: Int, stopPriority: Int) async throws -> [Todo] {
        let query = databaseManager.realm.objects(TodoEntity.self)
            //.filter("priority >= %@ && priority <= %@", startPriority, stopPriority)
            .where {
                $0.priority >= startPriority && $0.priority <= stopPriority
            }

        return query
            .sorted(by: \.priority)
            .map { $0.dao }
    }

    public func addNewTodo(name: String, comments: String, date: Date, priority: Int?, selectedGroup: Group) async throws {
        let todo = TodoEntity(name: name, date: date, priority: priority)
        todo.comments = comments
        todo.group = selectedGroupEntity(selectedGroup)
        try databaseManager.realm.write{
            databaseManager.realm.add(todo)
        }
    }

    public func updateTodo(_ editedTodo: Todo, name: String, comments: String, selectedGroup: Group) async throws {
        guard let todo = databaseManager.realm.object(ofType: TodoEntity.self, forPrimaryKey: editedTodo.id)
        else {
            return
        }
        try databaseManager.realm.write{
            todo.name = name
            todo.comments = comments
            todo.group = selectedGroupEntity(selectedGroup)
        }
    }

    private func selectedGroupEntity(_ selectedGroup: Group) -> TodoGroupEntity? {
        guard let id = selectedGroup.id else {
            return nil
        }
        return databaseManager.realm.object(ofType: TodoGroupEntity.self, forPrimaryKey: id)
    }

    public func removeAllTodos() async throws {
        let realm = databaseManager.realm
        try realm.write{
            let objects = realm.objects(TodoEntity.self)
            realm.delete(objects)
        }
    }
}

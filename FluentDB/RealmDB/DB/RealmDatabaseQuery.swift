//
//  RealmDatabaseQuery.swift
//  RealmDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation
import RealmSwift
import Core


struct RealmDatabaseQuery : DatabaseQueryProtocol {
    let databaseManager: DatabaseManager

    func getAllGroupsCount() async throws -> Int {
        databaseManager.realm.objects(TodoGroupEntity.self).count
    }

    func getAllGroups() async throws -> [Group] {
        return databaseManager.realm.objects(TodoGroupEntity.self)
            .sorted(by: \.name, ascending: true)
            .map { item in
                Group(id: item.id, name: item.name)
            }
    }

    func getGroups(with searchText: String) async throws -> [TodoGroup] {
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

    func addNewGroup(name: String) async throws {
        let group = TodoGroupEntity(name: name)
        try databaseManager.realm.write{
            databaseManager.realm.add(group)
        }
    }

    func removeAllGroups() async throws {
        let realm = databaseManager.realm
        try realm.write{
            let objects = realm.objects(TodoGroupEntity.self)
            realm.delete(objects)
        }
    }

    func getAllTasksCount() async throws -> Int {
        databaseManager.realm.objects(TodoEntity.self).count
    }

    func getTasksWithoutGroup() async throws -> [Todo] {
        return databaseManager.realm.objects(TodoEntity.self)
            .where {
                $0.group == nil
            }
            .map { $0.dao }
    }

    func getTasks(with searchText: String) async throws -> [Todo] {
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

    func addNewTodo(name: String, comments: String, selectedGroup: Group) async throws {
        let todo = TodoEntity(name: name)
        todo.comments = comments
        todo.group = selectedGroupEntity(selectedGroup)
        try databaseManager.realm.write{
            databaseManager.realm.add(todo)
        }
    }

    func updateTodo(_ editedTodo: Todo, name: String, comments: String, selectedGroup: Group) async throws {
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

    func removeAllTodos() async throws {
        let realm = databaseManager.realm
        try realm.write{
            let objects = realm.objects(TodoEntity.self)
            realm.delete(objects)
        }
    }
}

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

    func getAllGroups() async throws -> [Group] {
        return databaseManager.realm.objects(TodoGroupEntity.self)
            .sorted(by: \.name, ascending: true)
            .map { item in
                let id: UUID = UUID(uuidString: item.id) ?? UUID()
                return Group(id: id, name: item.name)
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
                let id: UUID = UUID(uuidString: item.id) ?? UUID()
                return TodoGroup(id: id, name: item.name, todos: item.todos.map{$0.dao})
            }
    }

    func addNewGroup(name: String) async throws {
        let group = TodoGroupEntity(name: name)
        try databaseManager.realm.write{
            databaseManager.realm.add(group)
        }
    }

    func getTasksWithoutGroup() async throws -> [Todo] {
        return databaseManager.realm.objects(TodoEntity.self)
            .where {
                $0.group == nil
            }
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
        guard let id = selectedGroup.id?.uuidString else {
            return nil
        }
        return databaseManager.realm.object(ofType: TodoGroupEntity.self, forPrimaryKey: id)
    }
}

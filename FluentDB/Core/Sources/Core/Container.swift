//
//  Container.swift
//
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation

final public class Container: ObservableObject {
    public var db: DatabaseProtocol
    public var dbQuery: DatabaseQueryProtocol

    public init(db: DatabaseProtocol, dbQuery: DatabaseQueryProtocol) {
        self.db = db
        self.dbQuery = dbQuery
    }
}

public protocol DatabaseQueryProtocol {

    func getAllGroupsCount() async throws -> Int
    func getAllGroups() async throws -> [Group]
    func getGroups(with searchText: String) async throws -> [TodoGroup]
    func addNewGroup(name: String) async throws
    func removeAllGroups() async throws

    func getAllTasksCount() async throws -> Int
    func getTasksWithoutGroup() async throws -> [Todo]
    func addNewTodo(name: String, comments: String, selectedGroup: Group) async throws
    func updateTodo(_ editedTodo: Todo, name: String, comments: String, selectedGroup: Group) async throws
    func removeAllTodos() async throws
}

public protocol DatabaseProtocol {

    func start() async
}

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



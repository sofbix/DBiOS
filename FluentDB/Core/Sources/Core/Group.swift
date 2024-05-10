//
//  Group.swift
//  
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation

public struct Group: Identifiable, Hashable {
    public var id: UUID?
    public var name: String

    public init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

public struct TodoGroup: Identifiable, Hashable {
    public var id: UUID?
    public var name: String
    public var todos: [Todo]

    public init(id: UUID? = nil, name: String, todos: [Todo]) {
        self.id = id
        self.name = name
        self.todos = todos
    }
}

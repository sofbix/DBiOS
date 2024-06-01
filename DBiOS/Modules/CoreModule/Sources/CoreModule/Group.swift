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

    // reserved
    public var data: EnityData?

    public init(id: UUID? = nil, name: String, data: EnityData? = nil) {
        self.id = id
        self.name = name
        self.data = data
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

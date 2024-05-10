//
//  TodoGroupEntity.swift
//  RealmDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation
import RealmSwift

final class TodoGroupEntity : Object {

    @Persisted(primaryKey: true) 
    var id: String

    @Persisted 
    var name: String

    @Persisted(originProperty: "group")
    var todos: LinkingObjects<TodoEntity>

    convenience init(id: UUID = UUID(), name: String) {
        self.init()
        self.id = id.uuidString
        self.name = name
    }
}

//
//  TodoEntity.swift
//  RealmDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation
import RealmSwift
import Core

final class TodoEntity : Object {

    @Persisted (primaryKey: true)
    var id: String

    @Persisted
    var name: String

    @Persisted 
    var comments: String?

    @Persisted 
    var date: Date?

    @Persisted
    var group: TodoGroupEntity?

    var count: Int = 0

    convenience init(id: UUID = UUID(), name: String, date: Date? = Date()) {
        self.init()
        self.id = id.uuidString
        self.name = name
        self.date = date
    }

    var dao: Todo {
        var date = ""
        if let rawDate = self.date {
            date = Self.dateFormatter.string(from: rawDate)
        }
        let id: UUID = UUID(uuidString: self.id) ?? UUID()
        let groupId: UUID = UUID(uuidString: self.group?.id ?? "") ?? UUID()
        return Todo(id: id, name: self.name, date: date, comments: self.comments, groupId: groupId, count: self.count)
    }

    static let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .short
        result.timeStyle = .medium
        return result
    }()
}


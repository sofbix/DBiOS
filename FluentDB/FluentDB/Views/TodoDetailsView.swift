//
//  TodoDetailsView.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 08.02.2024.
//

import SwiftUI

struct TodoDetailsView: View {

    @Environment(\.presentationMode)
    private var presentationMode

    @State
    private var name: String

    @State
    private var comments: String



    private var editedTodo: Todo?

    @State
    private var groups: [TodoGroup] = []
    @State
    private var selectedGroup: TodoGroup = TodoGroup(name: "", todos: [])

    private var handler: () -> Void

    init(editedTodo: Todo? = nil, handler: @escaping () -> Void) {
        _name = State<String>(wrappedValue: editedTodo?.name ?? "")
        _comments = State<String>(wrappedValue: editedTodo?.comments ?? "")
        self.editedTodo = editedTodo
        self.handler = handler
    }

    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $name)
                TextField("Comments", text: $comments)
                Section {
                    Picker("Group", selection: $selectedGroup) {
                        ForEach(groups, id: \.self) {
                            Text($0.name)
                        }
                    }
                }
            }
            Button(
                editedTodo != nil ? "Edit" : "Add",
                action: editedTodo != nil ? edit : add
            )
        }.onAppear {
            load()
        }
    }

    func add() {
        do {
            let todo = TodoEntity(id: nil, name: name)
            todo.comments = comments
            todo.$group.id = selectedGroup.id
            try todo.save(on: DatabaseManager.shared.db).wait()
            finish()
        } catch let error{
            print("Error: \(error)")
        }
    }

    func edit() {
        Task {
            do {
                guard let todo = try await TodoEntity.find(editedTodo?.id, on: DatabaseManager.shared.db).get() else {
                    return
                }
                todo.name = name
                todo.comments = comments
                todo.$group.id = selectedGroup.id
                try await  todo.save(on: DatabaseManager.shared.db)
                finish()
            } catch let error{
                print("Error: \(error)")
            }
        }
    }

    func load() {
        Task{ @MainActor in
            groups = try await DatabaseManager.shared.db.query(TodoGroupEntity.self)
                .sort(\.$name, .ascending)
                .all()
                .map{ item in
                    TodoGroup(id: item.id ?? UUID(), name: item.name, todos: [])
                }

            let selectedGroup: TodoGroup = groups.first{ item in
                item.id == editedTodo?.groupId
            } ?? groups.last ?? TodoGroup(name: "", todos: [])

            self.selectedGroup = selectedGroup
        }
    }

    func finish() {
        handler()
        presentationMode.wrappedValue.dismiss()
    }

}

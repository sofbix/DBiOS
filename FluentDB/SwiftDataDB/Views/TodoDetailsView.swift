//
//  TodoDetailsView.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 09.05.2024.
//

import SwiftUI
import SwiftData

struct TodoDetailsView: View {

    @Environment(\.modelContext)
    private var modelContext

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
            todo.group = TodoGroupEntity(id: selectedGroup.id, name: "")
            modelContext.insert(todo)
            try modelContext.save()
            finish()
        } catch let error{
            print("Error: \(error)")
        }
    }

    func edit() {
        Task { @MainActor in
            do {
                let newContext = ModelContext(DatabaseManager.shared.container)

                let id = editedTodo?.id
                guard let todo = try newContext.fetch(FetchDescriptor<TodoEntity>(
                    predicate: #Predicate<TodoEntity> { $0.id == id }
                )).first else {
                    return
                }
                todo.name = name
                todo.comments = comments
                todo.group = TodoGroupEntity(id: selectedGroup.id, name: "")
                try modelContext.save()
                finish()
            } catch let error{
                print("Error: \(error)")
            }
        }
    }

    func load() {
        Task{ @MainActor in
            let newContext = ModelContext(DatabaseManager.shared.container)
            let groupsPredicate = #Predicate<TodoGroupEntity>{ entity in
                true
            }
            let groupsDescriptor = FetchDescriptor<TodoGroupEntity>(
                predicate: groupsPredicate,
                sortBy: [SortDescriptor(\.name)]
            )
            groups = try newContext
                .fetch(groupsDescriptor)
                .map { item in
                    TodoGroup(id: item.id ?? UUID(), name: item.name, todos: item.todos.map{$0.dao})
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

//
//  TodoDetailsView.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 08.02.2024.
//

import SwiftUI

struct TodoDetailsView: View {

    @EnvironmentObject
    private var container: Container

    @Environment(\.presentationMode)
    private var presentationMode

    @State
    private var name: String

    @State
    private var comments: String



    private var editedTodo: Todo?

    @State
    private var groups: [Group] = []
    @State
    private var selectedGroup: Group = Group(name: "")

    private var handler: () -> Void

    init(editedTodo: Todo? = nil, handler: @escaping () -> Void) {
        _name = State<String>(wrappedValue: editedTodo?.name ?? "")
        _comments = State<String>(wrappedValue: editedTodo?.comments ?? "")
        self.editedTodo = editedTodo
        self.handler = handler
    }

    public var body: some View {
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
        Task {
            do {
                try await container.dbQuery.addNewTodo(name: name, comments: comments, selectedGroup: selectedGroup)
                Task { @MainActor in
                    finish()
                }
            } catch let error{
                print("Error: \(error)")
            }
        }
    }

    func edit() {
        Task {
            do {
                guard let editedTodo else {
                    return
                }
                try await container.dbQuery.updateTodo(editedTodo, name: name, comments: comments, selectedGroup: selectedGroup)
                Task { @MainActor in
                    finish()
                }
            } catch let error{
                print("Error: \(error)")
            }
        }
    }

    func load() {
        Task{ @MainActor in
            groups = try await container.dbQuery.getAllGroups()
            groups.append(Group(name: ""))

            var selectedGroup: Group = groups.first{ item in
                item.id == editedTodo?.groupId
            } ?? groups.last ?? Group(name: "")

            self.selectedGroup = selectedGroup
        }
    }

    func finish() {
        handler()
        presentationMode.wrappedValue.dismiss()
    }

}

//
//  TodoListView.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 08.02.2024.
//

import SwiftUI
import Combine
import Fluent

class TodoListViewModel: ObservableObject {
    @Published
    var groups: [TodoGroup] = []
    @Published
    var text: String = ""

    private var subscriptions = Set<AnyCancellable>()

    init(){
        $text
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink{ t in
                self.updateGroups()
            }
            .store(in: &subscriptions)
    }

    func updateGroups() {
        Task { @MainActor in
            var groups = try await DatabaseManager.shared.db.query(TodoGroupEntity.self)
                .filter(\.$name ~~ text)
                .sort(\.$name, .ascending)
                .with(\.$todos)
                .all()
                .map{ item in
                    TodoGroup(id: item.id ?? UUID(), name: item.name, todos: item.todos.map{$0.dao})
                }

            let todos = try await TodoEntity.query(on: DatabaseManager.shared.db)
                .filter(\TodoEntity.$group.$id, .equal, .none)
                .all()
                .map { $0.dao }

            groups.append(TodoGroup(id: nil, name: " ", todos: todos))
            self.groups = groups
        }
    }
}


struct TodoListView: View {

    @StateObject var vm = TodoListViewModel()

    // MARK: navigation triggers:

    @State
    private var isAddGroup = false
    @State
    private var isAddTodo = false
    @State
    private var editedTodo: Todo? = nil

    var body: some View {
        NavigationStack{
            VStack {
                List(vm.groups) { item in
                    Section(header: Text(item.name)) {
                        ForEach(item.todos) { item in
                            todoCell(item)
                        }
                    }
                }
                .listStyle(.grouped)
                buttonPanel
            }
        }
        .searchable(text: $vm.text)
        .onAppear{
            vm.updateGroups()
        }
        .sheet(isPresented: $isAddGroup) {
            AddGroupView(handler: vm.updateGroups)
        }
        .sheet(isPresented: $isAddTodo) {
            TodoDetailsView(
                handler: vm.updateGroups
            )
        }
        .sheet(item: $editedTodo) { todo in
            TodoDetailsView(
                editedTodo: todo, 
                handler: vm.updateGroups
            )
        }
    }

    @ViewBuilder
    var buttonPanel: some View {
        HStack{
            Spacer()
            Button("Add Group"){
                isAddGroup = true
            }
            Spacer()
            Button("Add Todo"){
                isAddTodo = true
            }
            Spacer()
        }
    }

    @ViewBuilder
    func todoCell(_ item: Todo) -> some View {
        Button {
            editedTodo = item
        } label: {
            VStack {
                HStack {
                    Text(item.date)
                    Text(" : ")
                    Text(item.name)
                    Spacer()
                }
                HStack {
                    Text(item.comments ?? "")
                    Spacer()
                }
            }.foregroundColor(.primary)
        }
    }
}

#Preview {
    TodoListView()
}

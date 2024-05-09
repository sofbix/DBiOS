//
//  TodoListView.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 09.05.2024.
//

import SwiftUI
import Combine
import SwiftData

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
            let newContext = ModelContext(DatabaseManager.shared.container)
            let groupsPredicate = #Predicate<TodoGroupEntity>{ entity in
                entity.name.contains(text) || text.isEmpty
            }
            let groupsDescriptor = FetchDescriptor<TodoGroupEntity>(
                predicate: groupsPredicate,
                sortBy: [SortDescriptor(\.name)]
            )
            var groups = try newContext
                .fetch(groupsDescriptor)
                .map { item in
                    TodoGroup(id: item.id ?? UUID(), name: item.name, todos: item.todos.map{$0.dao})
                }

            let todosPredicate = #Predicate<TodoEntity>{ entity in
                entity.group == nil
            }
            let todosDescriptor = FetchDescriptor<TodoEntity>(
                predicate: todosPredicate,
                sortBy: []
            )
            let todos = try newContext
                .fetch(todosDescriptor)
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

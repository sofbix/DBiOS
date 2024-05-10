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

    let container: Container

    @Published
    var groups: [TodoGroup] = []
    @Published
    var text: String = ""

    private var subscriptions = Set<AnyCancellable>()

    init(_ container: Container){
        self.container = container
        $text
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink{ t in
                self.updateGroups()
            }
            .store(in: &subscriptions)
    }

    func updateGroups() {
        Task { @MainActor in
            var groups = try await container.dbQuery.getGroups(with: text)

            let todos = try await container.dbQuery.getTasksWithoutGroup()

            groups.append(TodoGroup(id: nil, name: " ", todos: todos))
            self.groups = groups
        }
    }
}


struct TodoListView: View {

    @EnvironmentObject
    private var container: Container

    @StateObject 
    private var vm: TodoListViewModel

    init(container: Container) {
        self._vm = StateObject<TodoListViewModel>(wrappedValue: TodoListViewModel(container))
    }

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

//#Preview {
//    TodoListView(container: <#Container#>)
//}

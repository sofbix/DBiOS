//
//  FluentDBApp.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 08.02.2024.
//

import SwiftUI

final class Container: ObservableObject {
    var dbQuery: DatabaseQueryProtocol

    init(dbQuery: DatabaseQueryProtocol) {
        self.dbQuery = dbQuery
    }
}

struct StartView: View {
    @State
    private var isLoaded = false

    @StateObject
    private var container: Container

    init(dbQuery: DatabaseQueryProtocol) {
        self._container = StateObject<Container>(wrappedValue: Container(dbQuery: dbQuery))
    }

    var body: some View {
        if isLoaded {
            TodoListView(container: container)
                .environmentObject(container)
        } else {
            Text("Loading...").onAppear {
                loading()
            }
        }
    }

    func loading() {
        Task {
            await DatabaseManager.shared.start()
            Task{ @MainActor in
                isLoaded = true
            }
        }
    }
}

@main
struct FluentDBApp: App {

    var body: some Scene {
        WindowGroup {
            StartView(dbQuery: FluentDatabaseQuery(databaseManager: DatabaseManager.shared))
        }
    }

}

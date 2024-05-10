//
//  StartView.swift
//
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import SwiftUI

public struct StartView: View {
    @State
    private var isLoaded = false

    @StateObject
    private var container: Container

    public init(db: DatabaseProtocol, dbQuery: DatabaseQueryProtocol) {
        self._container = StateObject<Container>(wrappedValue: Container(db: db, dbQuery: dbQuery))
    }

    public var body: some View {
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
            await container.db.start()
            Task{ @MainActor in
                isLoaded = true
            }
        }
    }
}

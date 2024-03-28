//
//  FluentDBApp.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 08.02.2024.
//

import SwiftUI

@main
struct FluentDBApp: App {

    @State
    private var isLoaded = false

    var body: some Scene {
        WindowGroup {
            if isLoaded {
                TodoListView()
            } else {
                Text("Loading...").onAppear {
                    loading()
                }
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

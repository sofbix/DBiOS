//
//  SwiftDataDBApp.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 08.05.2024.
//

import SwiftUI

@main
struct SwiftDataDBApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListView()
                .modelContainer(DatabaseManager.shared.container)
        }
    }
}

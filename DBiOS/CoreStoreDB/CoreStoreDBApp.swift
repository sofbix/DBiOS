//
//  CoreStoreApp.swift
//  CoreStore
//
//  Created by Sergey Balalaev on 29.05.2024.
//

import SwiftUI
import Core
import CoreStoreModule

@main
struct CoreStoreApp: App {
    var body: some Scene {
        WindowGroup {
            StartView(db: DatabaseManager.shared, dbQuery: CoreStoreDatabaseQuery(databaseManager: DatabaseManager.shared))
        }
    }
}

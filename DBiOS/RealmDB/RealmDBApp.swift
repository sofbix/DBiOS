//
//  RealmDBApp.swift
//  RealmDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import SwiftUI
import Core
import RealmDBModule

@main
struct RealmDBApp: App {
    var body: some Scene {
        WindowGroup {
            StartView(db: DatabaseManager.shared, dbQuery: RealmDatabaseQuery(databaseManager: DatabaseManager.shared))
        }
    }
}

//
//  RealmDBApp.swift
//  RealmDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import SwiftUI
import CoreModule
import RealmModule

@main
struct RealmDBApp: App {
    var body: some Scene {
        WindowGroup {
            StartView(
                db: DatabaseManager.shared,
                dbQuery: DatabaseQuery(databaseManager: DatabaseManager.shared)
            )
        }
    }
}

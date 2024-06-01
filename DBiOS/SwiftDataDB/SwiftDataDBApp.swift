//
//  SwiftDataDBApp.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 08.05.2024.
//

import SwiftUI
import CoreModule
import SwiftDataModule

@main
struct SwiftDataDBApp: App {
    var body: some Scene {
        WindowGroup {
            StartView(db: DatabaseManager.shared, dbQuery: SwiftDataDatabaseQuery(databaseManager: DatabaseManager.shared))
        }
    }
}

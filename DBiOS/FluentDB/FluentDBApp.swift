//
//  FluentDBApp.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 08.02.2024.
//

import SwiftUI
import CoreModule
import FluentModule

@main
struct FluentDBApp: App {

    var body: some Scene {
        WindowGroup {
            StartView(db: DatabaseManager.shared, dbQuery: FluentDatabaseQuery(databaseManager: DatabaseManager.shared))
        }
    }

}

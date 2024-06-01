//
//  ContentView.swift
//  PerformanceAllDb
//
//  Created by Sergey Balalaev on 31.05.2024.
//

import SwiftUI
import CoreModule
import FluentModule
import RealmModule
import SwiftDataModule
import CoreStoreModule

struct ContentView: View {

    @State
    var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PerformanceFacadeView(name: "Fluent", db: FluentModule.DatabaseManager.shared, dbQuery: FluentModule.FluentDatabaseQuery(databaseManager: FluentModule.DatabaseManager.shared))
                .tabItem{
                    Image("Fluent")
                    Text("Fluent")
                }
                .tag(0)
            PerformanceFacadeView(name: "Realm", db: RealmModule.DatabaseManager.shared, dbQuery: RealmModule.RealmDatabaseQuery(databaseManager: RealmModule.DatabaseManager.shared))
                .tabItem{
                    Image("Realm")
                    Text("Realm")
                }
                .tag(1)
            PerformanceFacadeView(name: "SwiftData", db: SwiftDataModule.DatabaseManager.shared, dbQuery: SwiftDataModule.SwiftDataDatabaseQuery(databaseManager: SwiftDataModule.DatabaseManager.shared))
                .tabItem{
                    Image("SwiftData")
                    Text("SwiftData")
                }
                .tag(2)
            PerformanceFacadeView(name: "CoreStore", db: CoreStoreModule.DatabaseManager.shared, dbQuery: CoreStoreModule.CoreStoreDatabaseQuery(databaseManager: CoreStoreModule.DatabaseManager.shared))
                .tabItem{
                    Image("CoreStore")
                    Text("CoreStore")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}

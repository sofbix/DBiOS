//
//  DatabaseManager.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 08.05.2024.
//

import Foundation
import SwiftData
import Core

class DatabaseManager: DatabaseProtocol {

    static let shared = DatabaseManager()

    private let configuration : ModelConfiguration

    let container: ModelContainer

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    init() {
        let path = Self.getDocumentsDirectory().appendingPathComponent("sqlite.db")
        print(path.absoluteString)
        configuration = ModelConfiguration(
//            schema: Schema([
//
//            ]),
            url: path
        )
        container = try! ModelContainer(
            for: TodoEntity.self, TodoGroupEntity.self,
            migrationPlan: nil,
            configurations: configuration)
    }

    public func start() async {
        //
    }

}

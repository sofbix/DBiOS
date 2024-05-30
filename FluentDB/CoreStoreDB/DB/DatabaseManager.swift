//
//  DatabaseManager.swift
//  CoreStoreDB
//
//  Created by Sergey Balalaev on 29.05.2024.
//

import Foundation
import CoreStore
import Core

class DatabaseManager: DatabaseProtocol {

    static let shared = DatabaseManager()

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    var dataStack: DataStack {
        CoreStoreDefaults.dataStack
    }

    private static  func removeOldFilesFromRealmAtURL(realmURL: URL) {
        let directory = realmURL.deletingLastPathComponent()
        let fileName = realmURL.deletingPathExtension().lastPathComponent
        do {
            let existFiles = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil)
                .filter({
                    return $0.lastPathComponent.hasPrefix(fileName as String)
                })
            for oldFile in existFiles {
                try FileManager.default.removeItem(at: oldFile)
            }
        } catch let error as NSError {
            print(error)
        }
    }

    public func start() async {
        let url = Self.getDocumentsDirectory().appendingPathComponent("CoreStore.sqlite", isDirectory: false)
        let dataStack = DataStack(
            CoreStoreSchema(
                    modelVersion: "V1",
                    entities: [
                        Entity<TodoGroupEntity>("TodoGroup"),
                        Entity<TodoEntity>("Todo")
                    ]
                )
        )
        let storage = SQLiteStore(
            fileURL: url,
            //localStorageOptions: .allowSynchronousLightweightMigration
            localStorageOptions: .recreateStoreOnModelMismatch
        )
        print(url.absoluteString)
        do {
            //try CoreStoreDefaults.dataStack.addStorageAndWait()
            try dataStack.addStorageAndWait(storage)
            CoreStoreDefaults.dataStack = dataStack
        } catch let error as NSError {
            Self.removeOldFilesFromRealmAtURL(realmURL: url)
            print(error)
            _ = try? CoreStoreDefaults.dataStack.addStorageAndWait(storage)
        }
    }

}

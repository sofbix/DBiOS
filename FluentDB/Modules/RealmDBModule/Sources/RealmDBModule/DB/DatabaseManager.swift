//
//  DatabaseManager.swift
//  RealmDB
//
//  Created by Sergey Balalaev on 10.05.2024.
//

import Foundation
import RealmSwift
import Core

public class DatabaseManager: DatabaseProtocol {

    public static let shared = DatabaseManager()

    let realmURL: URL
    let configuration: Realm.Configuration

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public init() {
        realmURL = Self.getDocumentsDirectory().appendingPathComponent("realm.db", isDirectory: false)
        print(realmURL.absoluteString)
        configuration = Self.realmConfiguration(fileURL: realmURL)
    }

    var realm: Realm {
        openRealm()
    }

    public func openRealm() -> Realm {
        var realm: Realm? = nil
        do {
            realm = try Realm(configuration: configuration)
        } catch let error as NSError {
            print(error)
            Self.removeOldFilesFromRealmAtURL(realmURL: realmURL)
            realm = try! Realm(configuration: Self.realmConfiguration(fileURL: realmURL))
        }
        return realm!
    }

    private static func realmConfiguration(fileURL: URL) -> Realm.Configuration {
        let result = Realm.Configuration(
                fileURL: fileURL,
                inMemoryIdentifier: nil,
                encryptionKey: nil,
                readOnly: false,
                schemaVersion: 1,
                migrationBlock: nil,
                deleteRealmIfMigrationNeeded: false,
                objectTypes: nil)
        return result
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
        //
    }

}

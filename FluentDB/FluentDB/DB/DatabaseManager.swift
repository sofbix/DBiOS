//
//  DatabaseManager.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 03.03.2024.
//

import Foundation
import FluentSQLiteDriver
import Fluent
import NIO

class DatabaseManager {

    private static var threadsCount: Int {
        System.coreCount
    }

    private var group = MultiThreadedEventLoopGroup(numberOfThreads: threadsCount)
    private var pool = NIOThreadPool(numberOfThreads: threadsCount)
    private var log = Logger(label: "DB")
    private var migrations = Migrations()

    private var dbs: Databases?

    static let shared = DatabaseManager()

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    init() {


    }

    public func start() async {

        let path = getDocumentsDirectory().appendingPathComponent("sqlite.db")
        print(path.absoluteString)
        
        let configuration: SQLiteConfiguration = .init(storage:.file(path: path.absoluteString))

        pool.start()

        dbs = Databases(threadPool: pool, on: group)
        dbs?.use(.sqlite(configuration), as: .sqlite)

        migrations.add(CreateTodoEntity())
        migrations.add(DateTodoEntity())
        migrations.add(CreateTodoGroupEntity())
        migrations.add(GroupTodoEntity())

        do {
            try await autoMigrate()
        } catch let error {
            print("Error: \(error)")
        }
    }

    private var migrator: Migrator? {
        guard let dbs = self.dbs else { return nil }
        return Migrator(
            databases: dbs,
            migrations: self.migrations,
            logger: self.log,
            on: self.group.any(),
            migrationLogLevel: .trace
        )
    }

    /// Automatically runs forward migrations without confirmation.
    /// This can be triggered by passing `--auto-migrate` flag.
    private func autoMigrate() async throws {
        guard let migrator = self.migrator else { return }
        try await migrator.setupIfNeeded().flatMap {
            migrator.prepareBatch()
        }.get()
    }

    /// Automatically runs reverse migrations without confirmation.
    /// This can be triggered by passing `--auto-revert` during boot.
    private func autoRevert() async throws {
        guard let migrator = self.migrator else { return }
        try await migrator.setupIfNeeded().flatMap {
            migrator.revertAllBatches()
        }.get()
    }

    public var db: Database! {
        guard let dbs = self.dbs else { return nil }
        return dbs.database(logger: log, on: dbs.eventLoopGroup.next())
    }

    public func stop() {
        guard let dbs = self.dbs else { return }
        dbs.shutdown()
        self.dbs = nil

        do {
            try pool.syncShutdownGracefully()
        } catch {
            pool.shutdownGracefully { [weak self] in
                self?.log.error("(NIOThreadPool) Shutting Down with Error: \($0.debugDescription)")
            }
        }
        pool = NIOThreadPool(numberOfThreads: 0)

        do {
            try group.syncShutdownGracefully()
        } catch {
            group.shutdownGracefully { [weak self] in
                self?.log.error("(EventLoopGroup) Shutting Down with Error: \($0.debugDescription)")
            }
        }
        group = MultiThreadedEventLoopGroup(numberOfThreads: 0)
    }

    deinit {
        stop()
    }
}

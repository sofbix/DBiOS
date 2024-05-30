//
//  PerformanceFacadeView.swift
//
//
//  Created by Sergey Balalaev on 31.05.2024.
//

import SwiftUI

public struct PerformanceFacadeView: View {
    @State
    private var isLoaded = false

    @StateObject
    private var container: Container

    private let name: String

    public init(name: String, db: DatabaseProtocol, dbQuery: DatabaseQueryProtocol) {
        self._container = StateObject<Container>(wrappedValue: Container(db: db, dbQuery: dbQuery))
        self.name = name
    }

    public var body: some View {
        if isLoaded {
            PerformanceView(name: name)
                .environmentObject(container)
        } else {
            Text("Loading...").onAppear {
                loading()
            }
        }
    }

    func loading() {
        Task {
            await container.db.start()
            Task{ @MainActor in
                isLoaded = true
            }
        }
    }
}

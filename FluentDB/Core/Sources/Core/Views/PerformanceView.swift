//
//  PerformanceView.swift
//  
//
//  Created by Sergey Balalaev on 11.05.2024.
//

import SwiftUI

extension String: Identifiable {
    public var id: String {
        self
    }
}

public struct PerformanceView: View {

    @EnvironmentObject
    private var container: Container

    @State
    private var comments: [String] = []

    @State
    private var title: String = "Performance preparing"

    @State
    private var isCalculation: Bool = false

    @State
    private var groupsCount: Int = 0

    @State
    private var tasksCount: Int = 0

    public var body: some View {
        NavigationStack{
            VStack {
                buttonPanel
                List() {
                    Section(header: Text("Counts:")) {
                        Text("Groups: \(groupsCount)")
                        Text("Tasks: \(tasksCount)")
                    }
                    Section(header: Text("Results of performance:")) {
                        ForEach(comments) { item in
                            Text(item)
                        }
                    }
                }
                .listStyle(.grouped)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                calculateCounts()
            }
        }
    }

    @ViewBuilder
    var buttonPanel: some View {
        HStack{
            Spacer()
            Button("Clean"){
                clean()
                comments = []
            }
            Spacer()
            Button("Start"){
                start()
            }
            Spacer()
        }.disabled(isCalculation)
    }

    private func clean() {
        Task { @MainActor in
            isCalculation = true
            try await container.dbQuery.removeAllGroups()
            try await container.dbQuery.removeAllTodos()
            calculateCounts()
            isCalculation = false
        }
    }

    private func start() {
        Task {@MainActor in
            isCalculation = true
            Task {
                try await addGroups()
            }
        }
    }

    private func stop() {
        Task {@MainActor in
            calculateCounts()
            isCalculation = false
            title = "Calculation Finished"
        }
    }

    private func calculateCounts() {
        Task { @MainActor in
            groupsCount = try await container.dbQuery.getAllGroupsCount()
            tasksCount = try await container.dbQuery.getAllTasksCount()
        }
    }
}

extension PerformanceView {




    func addGroups() async throws {
        title = "Adding 10K Groups on Main Thread"
        let count = 10_000

        var startDate = Date()

        for i in 1...count{
            try await container.dbQuery.addNewGroup(name: "Group \(i)")
        }

        @MainActor func exit() {
            let sec = Date().timeIntervalSince(startDate)
            let frequency: Double = Double(count) / sec
            comments.append("10K Groups on Main Thread frequency (count per second): \(frequency)")
            stop()
        }

        exit()

//        try await withThrowingTaskGroup(of: Void.self) { group in
//            for i in 1...count{
//                group.addTask {
//                    await try container.dbQuery.addNewGroup(name: "Group \(i)")
//                }
//            }
//
//            try await group.waitForAll()
//
//            @MainActor func exit() {
//                let sec = Date().timeIntervalSince(startDate)
//                let frequency: Double = Double(count) / sec
//                comments.append("1M Groups on Main Thread frequency (count per second): \(frequency)")
//                stop()
//            }
//
//            exit()
//        }
    }
}

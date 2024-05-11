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

    @State
    private var iterationCount: Int = 10_000
    @State
    private var isCalculateAddingGroupsOneThread: Bool = true
    @State
    private var isCalculateAddingGroupsManyThreads: Bool = true

    public var body: some View {
        NavigationStack{
            VStack {
                buttonPanel
                List() {
                    Section(header: Text("Counts:")) {
                        Text("Groups: \(groupsCount)")
                        Text("Tasks: \(tasksCount)")
                    }
                    Section(header: Text("Calculation options:")) {
                        HStack {
                            Text("Iteration Count")
                            TextField("number", value: $iterationCount, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                        }
                        Toggle("Adding Groups on One Thread", isOn: $isCalculateAddingGroupsOneThread)
                        Toggle("Adding Groups on Many Threads", isOn: $isCalculateAddingGroupsManyThreads)
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
                if isCalculateAddingGroupsOneThread {
                    try await addGroupsOneThread()
                }
                if isCalculateAddingGroupsManyThreads {
                    try await addGroupsManyThreads()
                }
                stop()
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




    func addGroupsOneThread() async throws {
        let count = iterationCount
        var startDate = Date()

        await MainActor.run {
            title = "Adding \(count) Groups on One Thread"
            startDate = Date()
        }

        for i in 1...count{
            try await container.dbQuery.addNewGroup(name: "Group \(i)")
        }

        await MainActor.run {
            let sec = Date().timeIntervalSince(startDate)
            let frequency: Double = Double(count) / sec
            comments.append("\(count) Groups on One Thread frequency (count per second): \(frequency)")
        }

    }

    func addGroupsManyThreads() async throws {
        let count = iterationCount
        var startDate = Date()

        await MainActor.run {
            title = "Adding \(count) Groups on Groups Threads"
            startDate = Date()
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 1...count{
                group.addTask {
                    await try container.dbQuery.addNewGroup(name: "Group \(i)")
                }
            }

            try await group.waitForAll()

            await MainActor.run {
                let sec = Date().timeIntervalSince(startDate)
                let frequency: Double = Double(count) / sec
                comments.append("\(count) Groups on Groups Threads frequency (count per second): \(frequency)")
                stop()
            }
        }
    }
}

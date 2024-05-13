//
//  PerformanceView.swift
//  
//
//  Created by Sergey Balalaev on 11.05.2024.
//

import SwiftUI

struct Comment: Identifiable {
    let id: UUID
    let group: Group
    let comments: String
    let totalCount: Int
    let frequency: Int

    init(group: Group, comments: String, totalCount: Int, frequency: Int) {
        self.group = group
        self.id = UUID()
        self.comments = comments
        self.totalCount = totalCount
        self.frequency = frequency
    }

    enum Group: String {
        case addGroup, readGroup, addTodo, readTodoWithName, readTodoWithDate, readTodoWithPriority
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

public struct PerformanceView: View {

    static let weekMinutes: Int = 7*24*60

    @EnvironmentObject
    private var container: Container

    @State
    private var isShowSharing: Bool = false

    @State
    private var comments: [Comment] = []

    @State
    private var title: String = "Performance preparing"

    @State
    private var isCalculation: Bool = false
    @State
    private var isStopping: Bool = false

    @State
    private var groupsCount: Int = 0
    @State
    private var todosCount: Int = 0

    @State
    private var iterationCount: Int = 10_000
    @State
    private var waitSeconds: Int = 0
    @State
    private var repeatCount: Int = 1
    @State
    private var isCalculateOnManyThreads: Bool = false

    @State
    private var isCalculateAddingGroups: Bool = true
    @State
    private var isCalculateReadingGroups: Bool = true
    @State
    private var isCalculateAddingTodos: Bool = true
    @State
    private var isCalculateReadingTodosWithName: Bool = true
    @State
    private var isCalculateReadingTodosWithDate: Bool = true
    @State
    private var isCalculateReadingTodosWithPriority: Bool = true

    private static let sharedName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "shared"

    private let sharedPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(sharedName).csv")!

    public var body: some View {
        NavigationStack{
            VStack {
                buttonPanel
                List() {
                    Section(header: Text("Counts:")) {
                        Text("Groups: \(groupsCount)")
                        Text("Todos: \(todosCount)")
                    }
                    Section(header: Text("Calculation settings:")) {
                        HStack {
                            Text("Iteration Count")
                            TextField("number", value: $iterationCount, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                        }
                        Toggle("On Many Threads", isOn: $isCalculateOnManyThreads)
                        HStack {
                            Text("Wait pause (in sec.)")
                            TextField("number", value: $waitSeconds, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                        }
                        HStack {
                            Text("Repeat Count")
                            TextField("number", value: $repeatCount, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                        }
                    }
                    Section(header: Text("Calculation options:")) {
                        Toggle("Adding Groups", isOn: $isCalculateAddingGroups)
                        Toggle("Reading Groups", isOn: $isCalculateReadingGroups)
                        Toggle("Adding Todos", isOn: $isCalculateAddingTodos)
                        Toggle("Reading Todos with Name", isOn: $isCalculateReadingTodosWithName)
                        Toggle("Reading Todos with Date", isOn: $isCalculateReadingTodosWithDate)
                        Toggle("Reading Todos with Priority", isOn: $isCalculateReadingTodosWithPriority)
                    }
                    Section(header: Text("Results of performance:")) {
                        ForEach(comments) { item in
                            Text(item.comments)
                        }
                    }
                }
                .listStyle(.grouped)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                Task {
                    try await calculateCounts()
                }
            }
            .sheet(isPresented: $isShowSharing) {
                ActivityView(items: [sharedPath])
            }
        }
    }

    @ViewBuilder
    var buttonPanel: some View {
        if isCalculation {
            Button("Stop"){
                stopping()
            }.disabled(isStopping)
        } else {
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
                Button("Share"){
                    share()
                }
                Spacer()
            }
        }
    }

    private func clean() {
        Task { @MainActor in
            isStopping = false
            isCalculation = true
            try await container.dbQuery.removeAllGroups()
            try await container.dbQuery.removeAllTodos()
            try await calculateCounts()
            isCalculation = false
        }
    }

    private func start() {
        Task {
            await MainActor.run {
                isStopping = false
                isCalculation = true
            }
            for repeatIndex in 1...repeatCount {
                if isCalculateAddingGroups {
                    try await addGroups(repeatIndex)
                }
                if isCalculateReadingGroups {
                    try await readGroups(repeatIndex)
                }
                if isCalculateAddingTodos {
                    try await addTodos(repeatIndex)
                }
                if isCalculateReadingTodosWithName {
                    try await readTodosWithName(repeatIndex)
                }
                if isCalculateReadingTodosWithDate {
                    try await readTodosWithDate(repeatIndex)
                }
                if isCalculateReadingTodosWithPriority {
                    try await readTodosWithPriority(repeatIndex)
                }
                if isStopping {
                    break
                }
            }

            stop()
        }
    }

    private func stopping() {
        Task {@MainActor in
            isStopping = true
            title = "Stopping calculation..."
        }
    }

    private func stop() {
        Task {@MainActor in
            isCalculation = false
            title = "Calculation Finished"
        }
    }

    private func calculateCounts() async throws {
        let groupsCount = try await container.dbQuery.getAllGroupsCount()
        let todosCount = try await container.dbQuery.getAllTasksCount()
        await MainActor.run {
            self.groupsCount = groupsCount
            self.todosCount = todosCount
        }
    }
}

extension PerformanceView {

    func calculateFrequency(title: String, group: Comment.Group, handle: (_ index: Int) async throws -> Void) async throws {
        var iterationCount: Int = 0
        var isCalculateOnManyThreads: Bool = false
        var isStopping: Bool = false
        await MainActor.run {
            iterationCount = self.iterationCount
            isCalculateOnManyThreads = self.isCalculateOnManyThreads
            isStopping = self.isStopping
            self.title = title
        }
        guard isStopping == false else {
            return
        }
        var startDate = Date()

        if isCalculateOnManyThreads {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for i in 1...iterationCount{
                    group.addTask {
                        await try container.dbQuery.addNewGroup(name: "Group \(i)")
                    }
                }

                try await group.waitForAll()
            }
        } else {
            for i in 1...iterationCount{
                try await handle(i)
            }
        }

        let sec = Date().timeIntervalSince(startDate)
        try await calculateCounts()

        await MainActor.run {
            let frequency = Int(trunc(Double(iterationCount) / sec))
            let threads = isCalculateOnManyThreads ? "on Many Threads" : "on One Thread"

            var totalCount: Int = 0

            switch group {
            case .addGroup:
                totalCount = self.groupsCount
            case .readGroup:
                totalCount = self.groupsCount
            case .addTodo:
                totalCount = self.todosCount
            case .readTodoWithName, .readTodoWithDate, .readTodoWithPriority:
                totalCount = self.todosCount
            }

            let comment = Comment(group: group, comments: "\(title)\n\(threads)\nfrequency (count per sec.): \(frequency)\ntotal: \(totalCount) items", totalCount: totalCount, frequency: frequency)
            comments.append(comment)
        }

        if waitSeconds > 0, self.isStopping == false {
            await MainActor.run {
                self.title = "Waiting \(waitSeconds) sec."
            }
            try await Task.sleep(seconds: Double(waitSeconds))
        }
    }

    func addGroups(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Adding \(iterationCount) Groups", group: .addGroup) { index in
            try await container.dbQuery.addNewGroup(name: "Group \(index)")
        }
    }

    func readGroups(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Reading random \(iterationCount) Groups", group: .readGroup) { index in
            try await container.dbQuery.getGroups(with: UUID().uuidString)
        }
    }

    func addTodos(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Adding \(iterationCount) Todos", group: .addTodo) { index in
            var date = Date()
            let aditionHours = Double(Int.random(in: -Self.weekMinutes..<Self.weekMinutes))
            date.addTimeInterval(aditionHours * 60.0)
            let priority = Int.random(in: 0..<1000)
            try await container.dbQuery.addNewTodo(name: "Todo \(index)", comments: "Empty", date: date, priority: priority, selectedGroup: Group(name: ""))
        }
    }

    func readTodosWithName(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Reading random \(iterationCount) Todos with Name", group: .readTodoWithName) { index in
            try await container.dbQuery.getTasks(with: UUID().uuidString)
        }
    }

    func readTodosWithDate(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Reading random \(iterationCount) Todos with Date", group: .readTodoWithDate) { index in
            var date = Date()
            let aditionHours = Double(Int.random(in: -Self.weekMinutes..<Self.weekMinutes))
            date.addTimeInterval(aditionHours * 60.0)
            try await container.dbQuery.getTasks(startDate: date.addingTimeInterval(-600), stopDate: date.addingTimeInterval(600))
        }
    }

    func readTodosWithPriority(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Reading random \(iterationCount) Todos with Priority", group: .readTodoWithPriority) { index in
            let priority = Int.random(in: 0..<1000)
            try await container.dbQuery.getTasks(startPriority: priority, stopPriority: priority + 1)
        }
    }
}

extension PerformanceView {
    func share() {
        try? FileManager.default.removeItem(at: sharedPath)
        var headers: [Comment.Group] = []
        for comment in comments {
            let isFound = headers.contains { item in
                item == comment.group
            }
            if !isFound {
                headers.append(comment.group)
            }
        }

        var result = "number;"
        for header in headers {
            result += header.rawValue + ";"
            result += "totalCount;"
            result += "frequency;"
        }

        result += "\n"

        for (index, comment) in comments.enumerated() {
            if index % headers.count == 0 {
                let number = index / headers.count + 1
                result += "\(number);"
            }
            result += comment.comments.replacingOccurrences(of: "\n", with: "") + ";"
            result += "\(comment.totalCount)" + ";"
            result += "\(comment.frequency)" + ";"
            if index % headers.count == headers.count - 1 {
                result += "\n"
            }
        }

        do {
            try result.write(to: sharedPath, atomically: true, encoding: .utf8)
        } catch let error {
            print("Error sharing: \(error)")
        }

        isShowSharing = true
    }

}

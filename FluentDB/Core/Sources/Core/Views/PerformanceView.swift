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
    let value: String

    init(group: Group, comments: String, totalCount: Int, value: String) {
        self.group = group
        self.id = UUID()
        self.comments = comments
        self.totalCount = totalCount
        self.value = value
    }

    enum Group: String, CaseIterable {
        case addGroup, readGroup, addTodo, readTodoWithName, readTodoWithDate, readTodoWithPriority, random
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

public struct PerformanceView: View {

    let name: String
    private let sharedPath: URL
    private static let weekMinutes: Int = 7*24*60

    init(name: String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "App") {
        self.name = name
        sharedPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(name).csv")
        title = "Performance \(name)"
    }

    @EnvironmentObject
    private var container: Container

    @State
    private var isShowSharing: Bool = false

    @State
    private var comments: [Comment] = []

    @State
    private var title: String

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
    private var isCalculateAsync: Bool = false
    @State
    private var isCalculateFrequency: Bool = false

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
    @State
    private var isCalculateRandom: Bool = false

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
                                .padding(0)
                        }
                        Toggle("Async (parallel queries)", isOn: $isCalculateAsync)
                        Toggle("Result in Frequency (queries per second)", isOn: $isCalculateFrequency)
                        HStack {
                            Text("Wait pause (in sec.)")
                            TextField("number", value: $waitSeconds, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .padding(0)
                        }
                        HStack {
                            Text("Repeat Count")
                            TextField("number", value: $repeatCount, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .padding(0)
                        }
                    }.disabled(isCalculation)
                    Section(header: Text("Calculation options:")) {
                        Toggle("Adding Groups", isOn: $isCalculateAddingGroups)
                        Toggle("Reading Groups", isOn: $isCalculateReadingGroups)
                        Toggle("Adding Todos", isOn: $isCalculateAddingTodos)
                        Toggle("Reading Todos with Name", isOn: $isCalculateReadingTodosWithName)
                        Toggle("Reading Todos with Date", isOn: $isCalculateReadingTodosWithDate)
                        Toggle("Reading Todos with Priority", isOn: $isCalculateReadingTodosWithPriority)
                        Toggle("Random", isOn: $isCalculateRandom)
                    }.disabled(isCalculation)
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
                if isCalculateRandom {
                    try await random(repeatIndex)
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
            title = "Stopping \(name)..."
        }
    }

    private func stop() {
        Task {@MainActor in
            isCalculation = false
            title = "\(name) calculation finished"
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

    func calculateFrequency(title: String, group: Comment.Group, handle: @escaping  (_ index: Int) async throws -> Void) async throws {
        var iterationCount: Int = 0
        var isCalculateAsync: Bool = false
        var isStopping: Bool = false
        var isCalculateFrequency = false
        await MainActor.run {
            iterationCount = self.iterationCount
            isCalculateAsync = self.isCalculateAsync
            isCalculateFrequency = self.isCalculateFrequency
            isStopping = self.isStopping
            self.title = title
        }
        guard isStopping == false else {
            return
        }
        var startDate = Date()

        if isCalculateAsync {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for i in 1...iterationCount{
                    group.addTask {
                        await try handle(i)
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
            let frequency = Double(iterationCount) / sec
            let threads = isCalculateAsync ? "Async (parallel queries)" : "Sync (wait previous query)"

            var totalCount: Int = 0

            switch group {
            case .addGroup, .readGroup:
                totalCount = self.groupsCount
            case .addTodo, .readTodoWithName, .readTodoWithDate, .readTodoWithPriority:
                totalCount = self.todosCount
            case .random:
                totalCount = self.groupsCount + self.todosCount
            }

            let resultValue = isCalculateFrequency ? "\(Int(trunc(frequency)))" : String(format: "%5.2f", 1000.0 / frequency)

            let result = isCalculateFrequency ? "Frequency (count per sec.): \(resultValue)" : "One query call: \(resultValue) msec."

            let comment = Comment(group: group, comments: "\(title)\n\(threads)\n\(result)\ntotal: \(totalCount) items", totalCount: totalCount, value: resultValue)
            comments.append(comment)
        }

        if waitSeconds > 0, self.isStopping == false {
            await MainActor.run {
                self.title = "Waiting \(waitSeconds) sec. for \(name)"
            }
            try await Task.sleep(seconds: Double(waitSeconds))
        }
    }

    fileprivate func addGroupsOperation(_ index: Int) async throws {
        try await container.dbQuery.addNewGroup(name: "Group \(index)")
    }
    
    func addGroups(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Adding \(iterationCount) Groups", group: .addGroup) 
        { index in
            try await addGroupsOperation(index)
        }
    }

    fileprivate func readGroupsOperation() async throws -> [TodoGroup] {
        return try await container.dbQuery.getGroups(with: UUID().uuidString)
    }
    
    func readGroups(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Reading random \(iterationCount) Groups", group: .readGroup) 
        { index in
            try await readGroupsOperation()
        }
    }

    fileprivate func addTodosOperation(_ index: Int) async throws {
        var date = Date()
        let aditionHours = Double(Int.random(in: -Self.weekMinutes..<Self.weekMinutes))
        date.addTimeInterval(aditionHours * 60.0)
        let priority = Int.random(in: 0..<1000000)
        try await container.dbQuery.addNewTodo(name: "Todo \(index)", comments: "Empty", date: date, priority: priority, selectedGroup: Group(name: ""))
    }
    
    func addTodos(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Adding \(iterationCount) Todos", group: .addTodo) 
        { index in
            try await addTodosOperation(index)
        }
    }

    fileprivate func readTodosWithNameOperation() async throws -> [Todo] {
        return try await container.dbQuery.getTasks(with: UUID().uuidString)
    }
    
    func readTodosWithName(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Reading random \(iterationCount) Todos with Name", group: .readTodoWithName) 
        { index in
            try await readTodosWithNameOperation()
        }
    }

    fileprivate func readTodosWithDateOperation() async throws {
        var date = Date()
        let aditionHours = Double(Int.random(in: -Self.weekMinutes..<Self.weekMinutes))
        date.addTimeInterval(aditionHours * 60.0)
        try await container.dbQuery.getTasks(startDate: date.addingTimeInterval(-60), stopDate: date.addingTimeInterval(60))
    }
    
    func readTodosWithDate(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Reading random \(iterationCount) Todos with Date", group: .readTodoWithDate) 
        { index in
            try await readTodosWithDateOperation()
        }
    }

    fileprivate func readTodosWithPriorityOperation() async throws {
        let priority = Int.random(in: 0..<1000000)
        try await container.dbQuery.getTasks(startPriority: priority, stopPriority: priority + 10)
    }
    
    func readTodosWithPriority(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Reading random \(iterationCount) Todos with Priority", group: .readTodoWithPriority) 
        { index in
            try await readTodosWithPriorityOperation()
        }
    }

    func random(_ repeatIndex: Int) async throws {
        try await calculateFrequency(title: "\(repeatIndex). Random query with \(iterationCount) count", group: .readTodoWithPriority)
        { index in
            let index = Int.random(in: 0..<Comment.Group.allCases.count - 2)
            switch Comment.Group.allCases[index] {
            case .addGroup:
                try await addGroupsOperation(index)
            case .readGroup:
                try await readGroupsOperation()
            case .addTodo:
                try await addTodosOperation(index)
            case .readTodoWithName:
                try await readTodosWithNameOperation()
            case .readTodoWithDate:
                try await readTodosWithDateOperation()
            case .readTodoWithPriority:
                try await readTodosWithPriorityOperation()
            case .random:
                print("random")
            }
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
            result += isCalculateFrequency ? "frequency;" : "msec.;"
        }

        result += "\n"

        for (index, comment) in comments.enumerated() {
            if index % headers.count == 0 {
                let number = index / headers.count + 1
                result += "\(number);"
            }
            result += comment.comments.replacingOccurrences(of: "\n", with: ". ") + ";"
            result += "\(comment.totalCount)" + ";"
            result += "\(comment.value)" + ";"
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

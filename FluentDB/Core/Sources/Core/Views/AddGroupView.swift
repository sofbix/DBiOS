//
//  AddGroupView.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 04.03.2024.
//

import SwiftUI

struct AddGroupView: View {

    @EnvironmentObject
    private var container: Container

    @Environment(\.presentationMode)
    private var presentationMode

    @State
    private var name: String = ""

    var handler: () -> Void

    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $name)
            }
            Button("Add"){
                add()
            }
        }
    }

    func add() {
        Task {
            do {
                try await container.dbQuery.addNewGroup(name: name)
            } catch let error{
                print("Error: \(error)")
            }

            Task { @MainActor in
                handler()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

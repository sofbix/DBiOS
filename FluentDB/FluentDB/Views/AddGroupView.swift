//
//  AddGroupView.swift
//  FluentDB
//
//  Created by Sergey Balalaev on 04.03.2024.
//

import SwiftUI

struct AddGroupView: View {

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
        do {
            let group = TodoGroupEntity(id: nil, name: name)
            try group.save(on: DatabaseManager.shared.db).wait()
        } catch let error{
            print("Error: \(error)")
        }

        handler()

        presentationMode.wrappedValue.dismiss()
    }
}

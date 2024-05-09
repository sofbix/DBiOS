//
//  AddGroupView.swift
//  SwiftDataDB
//
//  Created by Sergey Balalaev on 09.05.2024.
//

import SwiftUI

struct AddGroupView: View {

    @Environment(\.modelContext)
    private var modelContext

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
            modelContext.insert(group)
            try modelContext.save()
        } catch let error{
            print("Error: \(error)")
        }

        handler()

        presentationMode.wrappedValue.dismiss()
    }
}

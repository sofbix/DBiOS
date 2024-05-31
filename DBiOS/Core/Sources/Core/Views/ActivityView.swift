//
//  ActivityView.swift
//
//
//  Created by Sergey Balalaev on 12.05.2024.
//

import UIKit
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {

    var items: [Any]
    var activities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}

}

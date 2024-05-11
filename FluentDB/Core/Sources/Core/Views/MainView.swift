//
//  MainView.swift
//
//
//  Created by Sergey Balalaev on 11.05.2024.
//

import SwiftUI

public struct MainView: View {

    @EnvironmentObject
    private var container: Container

    public var body: some View {
        TabView {
            PerformanceView()
                .tabItem{
                    Image(systemName: "gauge.open.with.lines.needle.67percent.and.arrowtriangle.and.car")
                    Text("Performance")
                }
                .tag(0)
            TodoListView(container: container)
                .tabItem{
                    Image(systemName: "play.display")
                    Text("Demo")
                }
                .tag(1)
        }
    }
}

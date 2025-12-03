//
//  KartStopperApp.swift
//  kartstopper
//
//  Created by Ashish Brahma on 16/09/25.
//
//  The main entry of the app.

import SwiftUI
import CoreData

@main
struct KartStopperApp: App {
    private var persistenceController = PersistenceController.shared
    @StateObject private var viewModel = ViewModel(budget: Budget())

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

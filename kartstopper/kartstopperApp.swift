//
//  kartstopperApp.swift
//  kartstopper
//
//  Created by Ashish Brahma on 05/09/25.
//

import SwiftUI
import SwiftData

@main
struct kartstopperApp: App {
    let persistenceController = PersistenceController.shared
    

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}

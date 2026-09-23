//
//  Checkcircle.swift
//  KartStopper
//
//  Created by Ashish Brahma on 20/09/26.
//
//  A SwiftUI label view that is used to mark an item as complete.

import SwiftUI
import CoreData
internal import Combine
internal import OSLog

struct Checkcircle: View {
    @ObservedObject var viewModel: ViewModel
    
    let logger = PersistenceController.shared.logger
    
    @Environment(\.managedObjectContext) private var viewContext
    
    let item: CDItem
    
    var body: some View {
        Label("Checkcircle", systemImage: item.isComplete ? "checkmark.circle.fill" : "circle")
            .imageScale(.large)
            .labelStyle(.iconOnly)
            .foregroundStyle(Color.accentColor)
            .padding(.trailing, Design.Padding.trailing)
            .onTapGesture {
                toggleStatus()
            }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            if !item.isUpdated {
                logger.error("Failed to toggle item's completion status. \(error.localizedDescription)")
            }
        }
    }
    
    private func toggleStatus() {
        viewModel.objectWillChange.send()
        item.isComplete.toggle()
        saveContext()
    }
}

#Preview {
    Checkcircle(viewModel: .preview,
                item: .preview)
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

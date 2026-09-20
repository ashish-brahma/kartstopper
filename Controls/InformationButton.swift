//
//  InformationButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 20/09/26.
//
//  A SwiftUI button view that is used to present an item's detail view.

import SwiftUI
import CoreData
internal import Combine

struct InformationButton: View {
    @ObservedObject var navModel: NavigationModel
    
    let item: CDItem
    @Binding var showItemInfo: Bool
    
    var body: some View {
        Button {
            navModel.selectedItem = item
            showItemInfo = true
        } label: {
            Label("Info", systemImage: "info.circle")
                .imageScale(.large)
                .tint(.info)
                .labelStyle(.iconOnly)
        }
    }
}

#Preview {
    InformationButton(navModel: NavigationModel(),
                      item: .preview,
                      showItemInfo: .constant(false))
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

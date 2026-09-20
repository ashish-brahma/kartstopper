//
//  ItemRowView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that shows metadata of an item in a cart.

import SwiftUI
import CoreData
internal import Combine

struct ItemRowView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var navModel: NavigationModel
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode
    
    let item: CDItem
    @Binding var showItemInfo: Bool
    let reader: GeometryProxy
    let deleteAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            rowLabel(isEditing: editMode?.wrappedValue.isEditing ?? true)
        }
        .opacity(editMode?.wrappedValue.isEditing ?? true ? 0.5 : 1)
        .swipeActions(edge: .trailing) {
            DeleteSwipeButton(action: deleteAction)
        }
        .swipeActions(edge: .trailing) {
            EditSwipeButton {
                navModel.selectedItem = item
                showItemInfo = true
            }
        }
    }
    
    @ViewBuilder
    private func rowLabel(isEditing: Bool) -> some View {
        HStack {
            if !isEditing {
                Checkcircle(viewModel: viewModel,
                            item: item)
            }
            
            columnLabel()
            Spacer()
            
            if !isEditing {
                InformationButton(navModel: navModel,
                                  item: item,
                                  showItemInfo: $showItemInfo)
            }
        }
    }
    
    private func columnLabel() -> some View {
        VStack(alignment: .leading) {
            ItemOverviewLabel(
                imageURL: item.imageURL,
                name: item.displayName,
                price: item.price,
                itemColor: item.itemColor,
                reader: reader
            )
            .frame(height: reader.size.height/6)
            
            QuantityStepper(viewModel: viewModel,
                            item: item)
            .frame(width: reader.size.width/2)
            .padding(.horizontal, Design.Padding.horizontal)
        }
        .frame(width: reader.size.width * 0.6,
               alignment: .leading)
    }
}

#Preview() {
    GeometryReader { reader in
        ItemRowView(viewModel: .preview,
                    navModel: NavigationModel(),
                    item: .preview,
                    showItemInfo: .constant(false),
                    reader: reader,
                    deleteAction: { })
        
        .position(x: reader.size.width/2,
                  y: reader.size.height/2)
        
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
    }
}

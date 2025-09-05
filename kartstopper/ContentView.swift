//
//  ContentView.swift
//  kartstopper
//
//  Created by Ashish Brahma on 05/09/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest<Cart>(
        sortDescriptors: [SortDescriptor(\.id)], animation: .default
    ) private var cart
    
    @FetchRequest<Item>(
        sortDescriptors: [SortDescriptor(\.id)], animation: .default
    ) private var item
    
    var body: some View {
        ForEach(cart) { list in
            Text("Sample cart created at \(list.timestamp?.formatted() ?? "NaT")")
        }
        
        ForEach(item) { item in
            Text("Sample item created at \(item.timestamp?.formatted() ?? "NaT")")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

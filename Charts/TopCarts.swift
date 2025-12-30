//
//  TopCarts.swift
//  KartStopper
//
//  Created by Ashish Brahma on 30/12/25.
//

import SwiftUI
import Charts
import CoreData

struct TopCarts: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)])
    private var carts: FetchedResults<CDCart>
    
    var data: [CartCountData] {
        var data = [CartCountData]()
        for cart in carts {
            data.append(
                .init(name: cart.displayName,
                      items: CDCart.getTotalItems(for: cart,          context: viewContext))
            )
        }
        data = data.sorted { $0.items > $1.items }
        return Array(data.prefix(5))
    }
    
    var topCartName: String {
        let max = data.map { $0.items }.max()
        let name = data.first(where: { $0.items == max })?.name
        return name ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Top Cart: \(topCartName)")
                .font(.caption)
            
            Chart(data, id: \.name) { element in
                BarMark(
                    x: .value("Items", element.items),
                    y: .value("Name", element.name)
                )
                .foregroundStyle(element.items == data.map { $0.items }.max() ? .accent : .secondary)
            }
        }
    }
}

struct CartCountData {
    let name: String
    let items: Int
}

#Preview {
    TopCarts()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


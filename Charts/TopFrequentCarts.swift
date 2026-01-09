//
//  TopFrequentCarts.swift
//  KartStopper
//
//  Created by Ashish Brahma on 30/12/25.
//
//  A chart view which visualizes the top 5 carts by item count.

import SwiftUI
import Charts
import CoreData

struct CartsFrequencyChart: View {
    var data: [CartCountData]
    
    var body: some View {
        Chart(data) { element in
            BarMark(
                x: .value("Items", element.itemCount),
                y: .value("Name", element.name)
            )
            .foregroundStyle(element.itemCount ==  CartCountData.getMaxCount(data: data) ? .mint : .secondary)
            .annotation {
                if element.itemCount ==  CartCountData.getMaxCount(data: data) {
                    Text("\(element.itemCount)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .overlay {
            if data.isEmpty {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct TopFrequentCarts: View {
    let reader: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)])
    private var carts: FetchedResults<CDCart>
    
    var data: [CartCountData] {
        CartCountData.topCartsData(carts: Array(carts),
                                   context: viewContext)
    }
    
    var topCartName: String {
        let name = data.first {
            $0.itemCount == CartCountData.getMaxCount(data: data)
        }?.name
        return name ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Most Frequent Cart")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text(data.isEmpty ? "-" : "\(topCartName)")
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
            
            HStack {
                Spacer(minLength: reader.size.width / 3)
                CartsFrequencyChart(data: data)
                    .padding(.top, -1.5 * Design.Padding.top)
                    .frame(height: 60)
            }
        }
    }
}

#Preview {
    GeometryReader { reader in
        VStack {
            TopFrequentCarts(reader: reader)
                .frame(height: 300)
        }
        .padding()
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}


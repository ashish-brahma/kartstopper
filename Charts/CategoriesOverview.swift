//
//  CategoriesOverview.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/01/26.
//
//  A chart view which visualizes the top 5 most expensive carts.

import SwiftUI
import Charts
import CoreData

struct CategoriesOverviewChart: View {
    var data: [CartExpenseData]
    
    var topCartName: String {
        let name = data.first {
            $0.expense == CartExpenseData.getMaxExpense(data: data)
        }?.name
        return name ?? ""
    }
    
    var body: some View {
        Chart(data) { element in
            if #available(iOS 17.0, *) {
                SectorMark(
                    angle: .value("Expenses", element.expense),
                    innerRadius: .ratio(0.618),
                    angularInset: 1
                )
                .cornerRadius(3.0)
                .foregroundStyle(by: .value("Name", element.name))
                .opacity(element.name == topCartName ? 1 : 0.3)
            } else {
                BarMark(
                    x: .value("Expenses", element.expense),
                    y: .value("Name", element.name)
                )
                .foregroundStyle(element.name == topCartName ? .pink : .secondary)
            }
        }
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

struct CategoriesOverview : View {
    let reader: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)])
    private var carts: FetchedResults<CDCart>
    
    var data: [CartExpenseData] {
        CartExpenseData.topCartsData(carts: Array(carts),
                                     context: viewContext)
    }
    
    var topCartName: String {
        let name = data.first {
            $0.expense == CartExpenseData.getMaxExpense(data: data)
        }?.name
        return name ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Most Expensive Cart")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text(data.isEmpty ? "-" : "\(topCartName)")
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
            
            CategoriesOverviewChart(data: data)
                .frame(height: 80)
        }
        .overlay {
            if data.isEmpty {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    GeometryReader { reader in
        VStack {
            CategoriesOverview(reader: reader)
                .frame(height: 300)
        }
        .padding()
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}


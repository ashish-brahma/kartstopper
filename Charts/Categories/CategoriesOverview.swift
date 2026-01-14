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
    
    @Environment(\.locale) private var locale
    
    var topCartName: String {
        data.first?.name ?? "Unknown"
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
                .annotation {
                    if element.name == topCartName {
                        Text("\(element.expense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

struct CategoriesOverview : View {
    var reader: GeometryProxy
    @State private var timeRange: TimeRange = .last30days
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)])
    private var carts: FetchedResults<CDCart>
    
    var filterDateRange: ClosedRange<Date> {
        let dateRange = CDItem.dateRange(context: viewContext)
        let start = dateRange.upperBound.addingTimeInterval(-1 * 3600 * 24 * timeRange.rawValue)
        let end = dateRange.upperBound
        return start...end
    }
    
    var data: [CartExpenseData] {
        let data = CartExpenseData.periodicData(
            range: filterDateRange,
            carts: Array(carts),
            context: viewContext
        )
        
        return CartExpenseData.sort(data, by: .expense)
    }
    
    var topCartName: String {
        data.first?.name ?? "Unknown"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Most Expensive Cart")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text(data.isEmpty ? "-" : "\(topCartName)")
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
            
            Text("Latest \(timeRange.rawValue, format: .number) Day Streak")
                .font(.headline)
                .foregroundStyle(.accent)
            
            HStack {
                Spacer(minLength: reader.size.width / 2.8)
                CategoriesOverviewChart(data: data)
                    .frame(height: 80)
            }
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


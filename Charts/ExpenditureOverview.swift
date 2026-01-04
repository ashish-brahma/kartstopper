//
//  ExpenditureOverview.swift
//  KartStopper
//
//  Created by Ashish Brahma on 30/12/25.
//
//  A chart which depicts expediture overview.

import SwiftUI
import Charts
import CoreData

struct ExpenditureOverviewChart: View {
    var data: [ExpenditureData]
    
    var body: some View {
        Chart(data) {
            BarMark(x: .value("Day", $0.date, unit: .day),
                    y: .value("Expenses", $0.expense))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .foregroundStyle(.sanskrit)
        .overlay {
            if data.isEmpty {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ExpenditureOverview: View {
    var range: ClosedRange<Date> = .startOfMonth(from: .now) ... .now
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var data: [ExpenditureData] {
        ExpenditureData.periodicData(range: range,
                                     context: viewContext)
    }
    
    var totalExpenditure: Double {
        data.map { $0.expense }.reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Expenditure")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text(totalExpenditure, format: .currency(code: locale.currency?.identifier ?? "USD"))
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
            
            ExpenditureOverviewChart(data: data)
                .frame(height: 100)
        }
    }
}

#Preview {
    let dateRange = CDItem.dateRange(context: PersistenceController.preview.container.viewContext)
    
    let start = dateRange.upperBound.addingTimeInterval(-1 * 3600 * 24 * 30)
    
    let end = dateRange.upperBound
    
    ExpenditureOverview(range: start...end)
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


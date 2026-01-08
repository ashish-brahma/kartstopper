//
//  ExpenditureOverview.swift
//  KartStopper
//
//  Created by Ashish Brahma on 03/01/26.
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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var timeRange: ClosedRange<Date> {
        ExpenditureData.lastNDaysRange(
            days: TimeRange.last30days.rawValue,
            context: viewContext
        )
    }
    
    var data: [ExpenditureData] {
        ExpenditureData.periodicData(range: timeRange,
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
    ExpenditureOverview()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


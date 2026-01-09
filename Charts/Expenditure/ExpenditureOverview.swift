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
    var reader: GeometryProxy
    @State private var timeRange: TimeRange = .last7days
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var filterDateRange: ClosedRange<Date> {
        ExpenditureData.lastNDaysRange(
            days: timeRange.rawValue,
            context: viewContext
        )
    }
    
    var data: [ExpenditureData] {
        ExpenditureData.periodicData(range: filterDateRange,
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
            
            Text("Latest \(timeRange.rawValue, format: .number) Day Streak")
                .font(.headline)
                .foregroundStyle(.accent)
            
            HStack {
                Spacer(minLength: reader.size.width / 2.8)
                ExpenditureOverviewChart(data: data)
                    .frame(height: 60)
            }
            .padding(.top, -1.5 * Design.Padding.top)
        }
    }
}

#Preview {
    GeometryReader { reader in
        VStack {
            ExpenditureOverview(reader: reader)
        }
        .frame(height: 300)
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}


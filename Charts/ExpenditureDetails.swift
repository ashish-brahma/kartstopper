//
//  ExpenditureDetails.swift
//  KartStopper
//
//  Created by Ashish Brahma on 30/12/25.
//
//  A chart which depicts expediture details.

import SwiftUI
import Charts
import CoreData

struct DailyExpenditureChart: View {
    var data: [ExpenditureData]
    
    var body: some View {
        Chart(data) {
            BarMark(x: .value("Day", $0.date, unit: .day),
                    y: .value("Expenses", $0.expense))
        }
        .foregroundStyle(.sanskrit)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
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

struct ExpenditureDetails: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var timeRange: ClosedRange<Date> {
        CDItem.dateRange(context: viewContext)
    }
    
    var data: [ExpenditureData] {
        ExpenditureData.periodicData(range: timeRange,
                                     context: viewContext)
    }
    
    var totalExpenditure: Double {
        data.map { $0.expense }.reduce(0, +)
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Total Expenditure")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Text(totalExpenditure, format: .currency(code: locale.currency?.identifier ?? "USD"))
                    .font(.title2.bold())
                    .foregroundStyle(Color.foreground)
                
                DailyExpenditureChart(data: data)
                    .frame(height: 240)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Total Expenditure")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ExpenditureDetails()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


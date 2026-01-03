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
    }
}

struct ExpenditureOverview: View {
    var range: ClosedRange<Date> = .startOfMonth(from: .now) ... .now
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var data: [ExpenditureData] {
        return ExpenditureData.periodicData(range: range,
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

struct ExpenditureData: Identifiable {
    let date: Date
    let expense: Double
    var id: Date { date }
}

extension ExpenditureData {
    static func periodicData(
        range: ClosedRange<Date>,
        context: NSManagedObjectContext
    ) ->  [ExpenditureData] {
        let items = CDItem.getExpenditure(in: range,
                                          context: context)
        return items.map {
            ExpenditureData(date: $0.timestamp ?? .now,
                            expense: $0.price * Double($0.quantity))
        }
    }
}

#Preview {
    ExpenditureOverview(range: CDItem.dateRange(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


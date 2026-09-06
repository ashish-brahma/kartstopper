//
//  TimeRangePicker.swift
//  KartStopper
//
//  Created by Ashish Brahma on 08/01/26.
//
//  A SwiftUI picker view which sets the time period of chart data.

import SwiftUI

struct TimeRangePicker: View {
    @Binding var value: TimeRange
    
    var body: some View {
        Picker(selection: $value.animation(.easeInOut)) {
            Text("W").tag(TimeRange.last7days)
            Text("M").tag(TimeRange.last30days)
            Text("Y").tag(TimeRange.last365days)
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    TimeRangePicker(value: .constant(TimeRange.last7days))
    TimeRangePicker(value: .constant(TimeRange.last30days))
    TimeRangePicker(value: .constant(TimeRange.last365days))
}

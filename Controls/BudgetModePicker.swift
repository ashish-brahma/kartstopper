//
//  BudgetModePicker.swift
//  KartStopper
//
//  Created by Ashish Brahma on 20/09/26.
//
//  A SwiftUI picker view which sets difficulty level of
//  budget in preferences.

import SwiftUI

struct BudgetModePicker: View {
    @Binding var difficulty: BudgetMode?
    
    var body: some View {
        Picker("Difficulty", selection: $difficulty) {
            ForEach(BudgetMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
    }
}

#Preview {
    List {
        BudgetModePicker(difficulty: .constant(.medium))
    }
}

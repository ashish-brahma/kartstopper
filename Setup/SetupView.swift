//
//  SetupView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/01/26.
//
//  A SwiftUI view which is used to onboard user.

import SwiftUI

struct SetupView: View {
    @Binding var showPreferences: Bool
    
    var body: some View {
        VStack {
            ContentView.unavailableView(label: "Create Budget",
                                        symbolName: "wrench.fill",
                                        description: "Budget amount would be used to track items marked as complete.")
            
            SettingsButton(showPreferences: $showPreferences,
                           configuration: .setup)
        }
        .padding()
    }
}

#Preview {
    SetupView(showPreferences: .constant(false))
}

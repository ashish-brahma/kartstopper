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
    @State var dismiss: Bool = false
    
    var body: some View {
        if !dismiss {
            HStack(alignment: .top) {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .imageScale(.large)
                    .font(.system(size: Design.setupImageFontSize,
                                  weight: .medium))
                    .foregroundStyle(.gray900)
                    .padding(.vertical, Design.Padding.vertical)
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("Create Budget")
                            .font(.headline)
                            .foregroundStyle(Color.foreground)
                        Spacer()
                        Button {
                            dismiss = true
                        } label: {
                            Label("Close", systemImage: "xmark")
                                .fontWeight(.medium)
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    HStack(alignment: .bottom) {
                        Text("Budget amount would be used to track items marked as complete.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        SettingsButton(showPreferences: $showPreferences,
                                       configuration: .setup)
                    }
                }
            }
        }
    }
}

#Preview {
    SetupView(showPreferences: .constant(false))
        .frame(height: 80)
}

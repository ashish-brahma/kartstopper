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
    @Binding var dismiss: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "number.square.fill")
                .imageScale(.large)
                .font(.system(size: Design.setupImageFontSize,
                              weight: .medium))
                .foregroundStyle(.gray900)
                .padding(.vertical, Design.Padding.vertical)
                .padding(.horizontal, Design.Padding.horizontal)
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("Create Budget")
                        .font(.headline)
                        .foregroundStyle(Color.foreground)
                    Spacer()
                    closeButton()
                }
                
                Text(Constants.Setup.purpose)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                ctaButton()
            }
        }
    }
    
    @ViewBuilder
    private func closeButton() -> some View {
        Button {
            dismiss = true
        } label: {
            Label("Close", systemImage: "xmark")
                .fontWeight(.medium)
                .labelStyle(.iconOnly)
                .foregroundStyle(.gray)
        }
    }
    
    @ViewBuilder
    private func ctaButton() -> some View {
        Button {
            showPreferences = true
        } label: {
            Label("Setup", systemImage: "plus.circle.fill")
                .bold()
                .foregroundStyle(Color.affirmative)
                .labelStyle(.titleOnly)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    SetupView(showPreferences: .constant(false),
              dismiss: .constant(false))
        .frame(height: 100)
}

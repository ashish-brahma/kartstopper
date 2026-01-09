//
//  SettingsButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/01/26.
//
//  A SwiftUI button view which is used to present ManageView sheet.

import SwiftUI

struct SettingsButtonContentView: View {
    @Binding var showPreferences: Bool
    let configuration: SettingsButtonType
    
    var body: some View {
        Button {
            showPreferences = true
        } label: {
            switch configuration {
            case .setup:
                Label("Setup", systemImage: "plus.circle.fill")
                    .bold()
                    .foregroundStyle(.gray700)
                    .labelStyle(.titleOnly)
            case .toolbar:
                Label("Manage", systemImage: "gearshape.fill")
                    .foregroundStyle(.accent)
                    .imageScale(.large)
                    .labelStyle(.iconOnly)
            }
        }
    }
}

struct SettingsButton: View {
    @Binding var showPreferences: Bool
    let configuration: SettingsButtonType
    
    var body: some View {
        switch configuration {
        case .setup:
            content()
                .buttonStyle(.borderless)
        case .toolbar:
            content()
                .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    func content() -> some View {
        SettingsButtonContentView(showPreferences: $showPreferences,
                                  configuration: configuration)
    }
}

enum SettingsButtonType {
    case setup
    case toolbar
}

#Preview("Toolbar") {
    SettingsButton(showPreferences: .constant(false),
                   configuration: .toolbar)
}

#Preview("Setup") {
    SettingsButton(showPreferences: .constant(false),
                   configuration: .setup)
}


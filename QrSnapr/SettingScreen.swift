//
//  SettingScreen.swift
//  QrSnapr
//
//  Created by Arnav Jindal on 4/4/24.
//

import Foundation
import SwiftUI
import KeyboardShortcuts

struct SettingsScreen: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("QR Code Scanning:", name: .toggleQrDetect)
        } .padding()
            .frame(width: 300, height: 100)
            .navigationTitle("Settings")
    }
}

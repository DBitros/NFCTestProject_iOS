//
//  NFCApp.swift
//  NFC
//
//  Created by Dionysios Bitros on 21/07/23.
//

import SwiftUI

@main
struct NFCApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: NFCViewModel())
        }
    }
}

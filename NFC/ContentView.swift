//
//  ContentView.swift
//  NFC
//
//  Created by Dionysios Bitros on 21/07/23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: NFCViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "creditcard")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Button("Tap Card", action: {
                viewModel.beginScanning()
            })
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: NFCViewModel())
    }
}

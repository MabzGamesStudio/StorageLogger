//
//  DeveloperSreenView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/23/25.
//

import SwiftUI

/// A view that displays the app information and developer support using Bitcoin Lightning.
struct DeveloperScreenView: View {
    
    /// The developer's Lightning address for receiving support.
    private let lightningAddress = "mabzlips@strike.me"
    
    /// The body of the view, describing its layout and UI elements.
    var body: some View {
        VStack(spacing: 20) {
            
            // App and developer information
            Text("Support the Developer")
                .font(.title)
                .fontWeight(.bold)
            Text("Storage Logger is a free and open source app")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Link("github.com/MabzGamesStudio/StorageLogger",
                 destination: URL(string: "https://github.com/MabzGamesStudio/StorageLogger")!)
            Text("Support the developer using Bitcoin Lightning with any small amount :)")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // QR code image generated from the Lightning address
            if let qrImage = QRCodeGenerator.generate(from: lightningAddress) {
                Image(uiImage: qrImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
            }
            
            // Display of the lightning address
            Text(lightningAddress)
                .font(.headline)
                .foregroundColor(.orange)
                .padding(.vertical, 5)
            
            // Button to copy the Lightning address to clipboard
            Button(action:  {
                UIPasteboard.general.string = lightningAddress
            }) {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text(verbatim: "Copy \(lightningAddress)")
                }
                .foregroundStyle(.white)
                .padding()
                .background(.orange)
                .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
    }
}

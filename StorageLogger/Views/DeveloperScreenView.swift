//
//  DeveloperSreenView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/23/25.
//

import SwiftUI

struct DeveloperScreenView: View {
    private let lightningAddress = "mabzlips@strike.me"
    
    var body: some View {
        VStack(spacing: 20) {
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
            
            if let qrImage = QRCodeGenerator.generate(from: lightningAddress) {
                Image(uiImage: qrImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
            }
            
            Text(lightningAddress)
                .font(.headline)
                .foregroundColor(.orange)
                .padding(.vertical, 5)
            
            Button(action: copyAddress) {
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
    
    private func copyAddress() {
        UIPasteboard.general.string = lightningAddress
    }
    
}

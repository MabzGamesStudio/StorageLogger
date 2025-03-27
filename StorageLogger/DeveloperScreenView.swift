//
//  DeveloperSreenView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/23/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct DeveloperScreenView: View {
    let lightningAddress = "mabzlips@strike.me"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Support the Developer")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Storage Logger is a free and open source app")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Link("GitHub.com/MabzGamesStudio/StorageLogger", destination: URL(string: "https://GitHub.com/MabzGamesStudio/StorageLogger")!)
            Text("Support the developer using Bitcoin Lightning with any small amount :)")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let qrImage = generateQRCode(from: lightningAddress) {
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
            
            Button(action: {
                UIPasteboard.general.string = lightningAddress
            }) {
                
                HStack {
                    Image(systemName: "doc.on.doc")
                        .foregroundStyle(.white)
                    Text(verbatim: "Copy mabzlips@strike.me")
                        .foregroundStyle(.white) // Force white text
                }
                .padding()
                .background(.orange)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

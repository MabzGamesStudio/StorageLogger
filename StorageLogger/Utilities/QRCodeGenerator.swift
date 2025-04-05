//
//  QRCodeGenerator.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/5/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins


struct QRCodeGenerator {
    static func generate(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

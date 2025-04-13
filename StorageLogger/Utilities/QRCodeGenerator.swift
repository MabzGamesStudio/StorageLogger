//
//  QRCodeGenerator.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/5/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

/// A utility for generating QR code images from a string.
struct QRCodeGenerator {
    
    /// Generates a QR code image from the provided string.
    ///
    /// - Parameter string: The input string to encode into a QR code.
    /// - Returns: A `UIImage` containing the QR code, or `nil` if generation fails.
    static func generate(from string: String) -> UIImage? {
        
        // Create a Core Image context for rendering the final QR code image and a CIFilter configured for QR code generation.
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        // Set the input message (encoded as UTF-8 data) for the QR code filter.
        filter.message = Data(string.utf8)
        
        // Attempt to generate the output CIImage and convert it into a CGImage, and return nil on failure.
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        // Convert the CGImage to a UIImage and return it.
        return UIImage(cgImage: cgImage)
    }
}

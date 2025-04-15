//
//  FileService.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/3/25.
//

import Foundation
import SwiftUI

/// Loads a UIImage from the app's documents directory under the "ImageData" folder.
///
/// - Parameter filename: The name of the image file to load.
/// - Returns: A `UIImage` if the file exists and is valid, otherwise `nil`.
func loadImageFromDocumentsDirectory(filename: String) -> UIImage? {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let imageDataFolderURL = documentsURL.appendingPathComponent("ImageData")
    let fileURL = imageDataFolderURL.appendingPathComponent(filename)
    if let imageData = try? Data(contentsOf: fileURL) {
        return UIImage(data: imageData)
    }
    return nil
}

/// Saves an image to the app's document directory in the "ImageData" folder using a base64-encoded string.
///
/// - Parameter base64String: A base64-encoded JPEG image string.
/// - Returns: The generated filename if saving is successful, otherwise `nil`.
func saveImage(base64String: String) -> String? {
    
    // Tries to encode the string, and returns nil on failure
    guard let imageData = Data(base64Encoded: base64String) else {
        print("Failed to decode base64 string")
        return nil
    }
    let imageDataFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("ImageData")
    
    // Tries to write the image data to the "ImageData" folder, and returns nil on failure
    do {
        let filename = UUID().uuidString + ".jpg"
        try FileManager.default.createDirectory(at: imageDataFolderURL, withIntermediateDirectories: true)
        try imageData.write(to: imageDataFolderURL.appendingPathComponent(filename))
        return filename
    } catch {
        print("Error saving image: \(error.localizedDescription)")
        return nil
    }
}

/// Saves a `UIImage` to disk by compressing it to be under a maximum file size.
///
/// - Parameter image: The `UIImage` to compress and save.
/// - Returns: The generated filename if saving is successful, otherwise `nil`.
func saveImage(image: UIImage) -> String? {
    
    // Maximum file size set to be 100kb
    let maxFileSizeKB = 100
    let maxFileSize = maxFileSizeKB * 1024
    var compressedQuality: CGFloat = 0.7
    var resizedImage = image
    var imageData: Data? = image.jpegData(compressionQuality: compressedQuality)
    
    // Gradually decrease compressed quality value until the image fits under the size limit
    while let data = imageData, data.count > maxFileSize && compressedQuality >= 0.1 {
        compressedQuality -= 0.1
        guard let newImage = resizeImage(image: image, scale: compressedQuality) else { break }
        resizedImage = newImage
        imageData = resizedImage.jpegData(compressionQuality: compressedQuality)
    }
    guard let finalData = imageData else { return nil }
    let filename = UUID().uuidString + ".jpg"
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let imageDataFolderURL = documentsURL.appendingPathComponent("ImageData")
    let fileURL = imageDataFolderURL.appendingPathComponent(filename)
    
    // Ensure the directory exists
    if !FileManager.default.fileExists(atPath: imageDataFolderURL.path) {
        do {
            try FileManager.default.createDirectory(at: imageDataFolderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error)")
        }
    }
    
    // Tries to write the image data to the "ImageData" folder, and returns nil on failure
    do {
        try finalData.write(to: fileURL)
        return filename
    } catch {
        print("Failed to save image: \(error)")
        return nil
    }
}

/// Restores a list of entries from compressed JSON data.
///
/// - Parameters:
///   - jsonData: The JSON data containing the entries (possibly with base64-encoded images).
///   - intersection: If provided, only add entries that don't already exist by ID. If `nil`, this is a full replacement.
/// - Returns: An array of `Entry` objects.
func restoreEntries(from jsonData: Data, intersection: [Entry]?) -> [Entry] {
    
    // Decode given JSON data to Entry with base64-encoded images
    guard let decodedEntries = decodeEntries(from: jsonData) else {
        return []
    }
    
    // If not merging with existing data, clear image directory to avoid orphans
    if intersection == nil {
        clearImageDataFolder()
    }
    
    // Initialize entries based utilizing either combine or replacement
    var restoredEntries: [Entry] = intersection ?? []
    
    // Add each decoded entry in the JSON data
    for importedEntry in decodedEntries {
        let entryAlreadyExists = !restoredEntries.contains(where: { $0.id == importedEntry.id })
        
        // If merging, skip duplicates
        guard intersection == nil || entryAlreadyExists else {
            continue
        }
        
        // Save image locally and create new entry, and save the image data
        if let imageBase64 = importedEntry.imageBase64,
           let filename = saveImage(base64String: imageBase64){
            restoredEntries.append(Entry(
                id: importedEntry.id,
                imageFilename: filename,
                name: importedEntry.name,
                price: importedEntry.price,
                quantity: importedEntry.quantity,
                description: importedEntry.description,
                notes: importedEntry.notes,
                tags: importedEntry.tags,
                buyDate: importedEntry.buyDate
            ))
        }
    }
    return restoredEntries
}

/// Deletes all files in the "ImageData" directory.
///
/// Used when replacing the entire dataset to avoid leaving behind unused image files.
private func clearImageDataFolder() {
    let imageDataFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("ImageData")
    do {
        let fileManager = FileManager.default
        let fileURLs = try fileManager.contentsOfDirectory(at: imageDataFolderURL, includingPropertiesForKeys: nil, options: [])
        for fileURL in fileURLs {
            try fileManager.removeItem(at: fileURL)
        }
    } catch {
        print("Failed to clear ImageData folder: \(error)")
    }
}

/// Resizes an image to a smaller size using the scale factor.
///
/// - Parameters:
///   - image : The image to resize.
///   - scale: The scaling factor of the image to reduce its size, from 0 to 1.
/// - Returns: The resized image.
private func resizeImage(image: UIImage, scale: CGFloat) -> UIImage? {
    let newSize = CGSize(
        width: image.size.width * scale,
        height: image.size.height * scale
    )
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1.0
    format.opaque = false
    let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
    let resizedImage = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize).integral)
    }
    return resizedImage
}

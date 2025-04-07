//
//  FileService.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/3/25.
//

import Foundation
import SwiftUI

func loadImageFromDocumentsDirectory(filename: String) -> UIImage? {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let imageDataFolderURL = documentsURL.appendingPathComponent("ImageData")
    let fileURL = imageDataFolderURL.appendingPathComponent(filename)
    
    if let imageData = try? Data(contentsOf: fileURL) {
        return UIImage(data: imageData)
    }
    return nil
}

func saveImage(fromBase64 base64String: String, filename: String) {
    
    guard let imageData = Data(base64Encoded: base64String) else {
        print("Failed to decode base64 string")
        return
    }
        
    let imageDataFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("ImageData")
    
    do {
        try FileManager.default.createDirectory(at: imageDataFolderURL, withIntermediateDirectories: true)
        try imageData.write(to: imageDataFolderURL.appendingPathComponent(filename))
    } catch {
        print("Error saving image: \(error.localizedDescription)")
    }
}

func saveImage(image: UIImage) -> String? {
    
    let maxFileSizeKB = 150
    let maxFileSize = maxFileSizeKB * 1024
    var compression: CGFloat = 0.0
    var imageData: Data? = image.jpegData(compressionQuality: compression)
    
    while let data = imageData, data.count > maxFileSize, compression > 0.01 {
        compression -= 0.01
        imageData = image.jpegData(compressionQuality: compression)
    }
    
    guard let finalData = imageData else { return nil }
    
    let filename = UUID().uuidString + ".jpg"
    
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let imageDataFolderURL = documentsURL.appendingPathComponent("ImageData")
    if !FileManager.default.fileExists(atPath: imageDataFolderURL.path) {
        do {
            try FileManager.default.createDirectory(at: imageDataFolderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error)")
        }
    }
    let fileURL = imageDataFolderURL.appendingPathComponent(filename)
    
    do {
        try finalData.write(to: fileURL)
        return filename
    } catch {
        print("Failed to save image: \(error)")
        return nil
    }
}

func restoreEntries(from jsonData: Data, intersection: [Entry]?) -> [Entry] {

    guard let decodedEntries = decodeEntries(from: jsonData) else {
        return []
    }
    
    if intersection == nil {
        clearImageDataFolder()
    }

    var restoredEntries: [Entry] = intersection ?? []

    for importedEntry in decodedEntries {
        let filename = UUID().uuidString + ".jpg"
        
        let entryAlreadyExists = !restoredEntries.contains(where: { $0.id == importedEntry.id })
        
        guard intersection == nil || entryAlreadyExists else {
            continue
        }
        
        if let imageBase64 = importedEntry.imageBase64 {
            saveImage(fromBase64: imageBase64, filename: filename)
        }
        
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

    return restoredEntries
}

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

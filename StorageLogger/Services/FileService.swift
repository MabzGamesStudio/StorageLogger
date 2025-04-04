//
//  FileService.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/3/25.
//

import Foundation

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

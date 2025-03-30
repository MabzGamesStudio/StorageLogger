import Foundation
import UIKit

struct Entry: Identifiable, Codable {
    var id: String
    var imageFilename: String?
    var name: String?
    var price: Double?
    var quantity: Int?
    var description: String?
    var notes: String?
    var tags: String?
    var buyDate: Date?
}

struct EntryWithBase64: Identifiable, Codable {
    var id: String
    var imageBase64: String?
    var name: String?
    var price: Double?
    var quantity: Int?
    var description: String?
    var notes: String?
    var tags: String?
    var buyDate: Date?
}

func convertImageToBase64(filename: String?) -> String? {
    guard let filename = filename else { return nil }
    
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(filename)
    
    if let imageData = try? Data(contentsOf: fileURL) {
        return imageData.base64EncodedString()
    } else {
        return nil
    }
}

func convertEntriesToJson(entries: [Entry]) -> String? {
    let entriesWithBase64 = entries.map { entry in
        EntryWithBase64(
            id: entry.id,
            imageBase64: convertImageToBase64(filename: entry.imageFilename),
            name: entry.name,
            price: entry.price,
            quantity: entry.quantity,
            description: entry.description,
            notes: entry.notes,
            tags: entry.tags,
            buyDate: entry.buyDate
        )
    }
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    encoder.dateEncodingStrategy = .iso8601 // Formats date as ISO 8601
    
    if let jsonData = try? encoder.encode(entriesWithBase64),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
    } else {
        return nil
    }
}

func decodeEntries(from jsonData: Data) -> [EntryWithBase64]? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601 // Ensure dates are properly decoded
    do {
        return try decoder.decode([EntryWithBase64].self, from: jsonData)
    } catch {
        print("Error decoding JSON: \(error.localizedDescription)")
        return nil
    }
}

func saveImage(fromBase64 base64String: String, filename: String) {
    if let imageData = Data(base64Encoded: base64String) {
        
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
            try imageData.write(to: fileURL)
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
        }
    } else {
        print("Failed to decode base64 string")
    }
}

func restoreEntries(from jsonData: Data, intersection: [Entry]?) -> [Entry] {
    // Decode the JSON into EntryWithBase64 objects
    guard let decodedEntries = decodeEntries(from: jsonData) else {
        return []
    }
    
    if intersection == nil {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageDataFolderURL = documentsURL.appendingPathComponent("ImageData")

        do {
            let fileManager = FileManager.default
            let fileURLs = try fileManager.contentsOfDirectory(at: imageDataFolderURL, includingPropertiesForKeys: nil, options: [])

            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
            
            print("All files in ImageData folder have been deleted.")
        } catch {
            print("Failed to clear ImageData folder: \(error)")
        }
    }

    var restoredEntries: [Entry] = intersection ?? []

    // Iterate over each decoded EntryWithBase64 and convert to Entry
    for entryWithBase64 in decodedEntries {
        // Handle base64 to image conversion
        let filename = UUID().uuidString + ".jpg"
        let entry = Entry(id: entryWithBase64.id,
                          imageFilename: filename,
                          name: entryWithBase64.name,
                          price: entryWithBase64.price,
                          quantity: entryWithBase64.quantity,
                          description: entryWithBase64.description,
                          notes: entryWithBase64.notes,
                          tags: entryWithBase64.tags,
                          buyDate: entryWithBase64.buyDate)
        
        if intersection == nil || !restoredEntries.contains(where: { $0.id == entryWithBase64.id }) {
            // Convert the base64 image data to a file if it exists
            if let imageBase64 = entryWithBase64.imageBase64 {
                saveImage(fromBase64: imageBase64, filename: filename)
            }
            
            // Append the converted entry to the result list
            restoredEntries.append(entry)
        }
        
    }

    return restoredEntries
}

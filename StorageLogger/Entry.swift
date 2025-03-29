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

func saveImage(fromBase64 base64String: String, filename: String) -> URL? {
    guard let imageData = Data(base64Encoded: base64String) else {
        print("Failed to decode base64 string")
        return nil
    }

    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(filename)

    do {
        try imageData.write(to: fileURL)
        return fileURL
    } catch {
        print("Failed to save image: \(error.localizedDescription)")
        return nil
    }
}

func restoreEntries(from jsonData: Data) -> [Entry] {
    // Decode the JSON into EntryWithBase64 objects
    guard let decodedEntries = decodeEntries(from: jsonData) else {
        return []
    }

    var restoredEntries: [Entry] = []

    // Iterate over each decoded EntryWithBase64 and convert to Entry
    for entryWithBase64 in decodedEntries {
        // Handle base64 to image conversion
        var entry = Entry(id: entryWithBase64.id,
                          imageFilename: nil, // Default to nil, will update if image exists
                          name: entryWithBase64.name,
                          price: entryWithBase64.price,
                          quantity: entryWithBase64.quantity,
                          description: entryWithBase64.description,
                          notes: entryWithBase64.notes,
                          tags: entryWithBase64.tags,
                          buyDate: entryWithBase64.buyDate)
        
        // Convert the base64 image data to a file if it exists
        if let imageBase64 = entryWithBase64.imageBase64 {
            let filename = UUID().uuidString + ".jpg" // Generate a unique filename
            if let imageURL = saveImage(fromBase64: imageBase64, filename: filename) {
                entry.imageFilename = imageURL.path // Assign the file path to the Entry
            }
        }
        
        // Append the converted entry to the result list
        restoredEntries.append(entry)
    }

    return restoredEntries
}

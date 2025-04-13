//
//  EntriesUtils.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/3/25.
//

import Foundation

/// Decodes an array of `EntryWithBase64` objects from JSON data.
///
/// - Parameter jsonData: The raw JSON data.
/// - Returns: An array of `EntryWithBase64` instances if decoding is successful, otherwise `nil`.
func decodeEntries(from jsonData: Data) -> [EntryWithBase64]? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try? decoder.decode([EntryWithBase64].self, from: jsonData)
}

/// Converts an array of `Entry` objects into a pretty-printed JSON string, with embedded base64 image data and iso8601 date encoding.
///
/// - Parameter entries: An array of `Entry` objects.
/// - Returns: A JSON string representation of the entries (as `EntryWithBase64`) if encoding succeeds, otherwise `nil`.
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
    encoder.dateEncodingStrategy = .iso8601
    return try? String(data: encoder.encode(entriesWithBase64), encoding: .utf8)
}

/// Converts a saved image file (referenced by filename) into a base64-encoded string.
///
/// - Parameter filename: The image filename located in the "ImageData" directory.
/// - Returns: A base64-encoded string of the image data if successful, otherwise `nil`.
private func convertImageToBase64(filename: String?) -> String? {
    guard let filename = filename else { return nil }
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("ImageData")
        .appendingPathComponent(filename)
    return try? Data(contentsOf: fileURL).base64EncodedString()
}

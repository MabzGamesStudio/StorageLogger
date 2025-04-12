//
//  EntriesUtils.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/3/25.
//

import Foundation

func restoreEntries(from data: Data) -> [Entry] {
    let decoder = JSONDecoder()
    return (try? decoder.decode([Entry].self, from: data)) ?? []
}

func mergeEntries(existing: [Entry], new: [Entry]) -> [Entry] {
    var merged = existing
    let existingIDs = Set(existing.map { $0.id })
    for entry in new where !existingIDs.contains(entry.id) {
        merged.append(entry)
    }
    return merged
}

func decodeEntries(from jsonData: Data) -> [EntryWithBase64]? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try? decoder.decode([EntryWithBase64].self, from: jsonData)
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
    encoder.dateEncodingStrategy = .iso8601
    
    return try? String(data: encoder.encode(entriesWithBase64), encoding: .utf8)
}

private func convertImageToBase64(filename: String?) -> String? {
    guard let filename = filename else { return nil }

    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("ImageData")
        .appendingPathComponent(filename)

    return try? Data(contentsOf: fileURL).base64EncodedString()
}

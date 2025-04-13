//
//  Entry.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/3/25.
//

import Foundation

/// A model representing an item entry, such as a product or record, optionally with image and data information.
///
/// Conforms to `Identifiable` for use in SwiftUI lists and `Codable` for JSON encoding/decoding.
struct Entry: Identifiable, Codable {
    
    /// A unique identifier for the entry.
    var id: String
    
    /// The filename of the image associated with the entry, if it exists.
    var imageFilename: String?
    
    /// The name of the entry.
    var name: String?
    
    /// The price value associated with the entry.
    var price: Double?
    
    /// The quantity of the items for this entry.
    var quantity: Int?
    
    /// A description about the entry.
    var description: String?
    
    /// Notes about the entry.
    var notes: String?
    
    /// Tags associated with the entry.
    var tags: String?
    
    /// The date when the item was bought or recorded.
    var buyDate: Date?
}

/// A variant of `Entry` used when the image is represented as a base64 string instead of a filename.
///
/// Used for serialization and transmission when image data is embedded in JSON.
/// Also conforms to `Identifiable` and `Codable`.
struct EntryWithBase64: Identifiable, Codable {
    
    /// A unique identifier for the entry.
    var id: String
    
    /// The base64-encoded image string associated with the entry.
    var imageBase64: String?
    
    /// The name of the entry.
    var name: String?
    
    /// The price value associated with the entry.
    var price: Double?
    
    /// The quantity of the items for this entry.
    var quantity: Int?
    
    /// A description about the entry.
    var description: String?
    
    /// Notes about the entry.
    var notes: String?
    
    /// Tags associated with the entry.
    var tags: String?
    
    /// The date when the item was bought or recorded.
    var buyDate: Date?
}

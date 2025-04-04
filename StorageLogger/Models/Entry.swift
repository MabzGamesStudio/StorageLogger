//
//  Entry.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/3/25.
//

import Foundation

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

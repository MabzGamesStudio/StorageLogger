//
//  DataStore.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/16/25.
//

import SwiftUI

/// A class that manages a collection of `Entry` objects and an ad counter, and handles their persistence.
///
/// The entries are stored in `UserDefaults`, and associated images are saved to disk.
class DataStore: ObservableObject {
    
    /// The list of saved entries. Automatically persisted whenever modified.
    @Published var entries: [Entry] = [] {
        didSet { saveEntries() }
    }
    
    /// A counter used to determine when to show ads. Persisted using `UserDefaults`.
    var counterForAd: Int {
        didSet { UserDefaults.standard.set(counterForAd, forKey: adCounterKey) }
    }

    /// The key used to persist `entries` in `UserDefaults`.
    private let storageKey = "entries"
    
    /// The key used to persist `counterForAd` in `UserDefaults`.
    private let adCounterKey = "counterForAd"

    /// Initializes the data store, sets the ad counter, and loads saved entries.
    init() {
        counterForAd = 1
        loadEntries()
    }

    /// Increments the ad counter by 1.
    func incrementCounterForAd() { counterForAd += 1 }
    
    /// Resets the ad counter to 1.
    func resetCounterForAd() { counterForAd = 1 }
    
    /// Adds a new entry to the store, saving any associated image.
    ///
    /// - Parameters:
    ///   - entry: The entry to add.
    ///   - image: An optional image to associate with the entry.
    func addEntry(entry: Entry, image: UIImage?) {
        
        // Formats and sets all data that has non-empty input
        let imageFilename = image.flatMap { saveImage(image: $0) }
        let price = entry.price.flatMap { $0.isNaN ? nil : $0 }
        let quantity = entry.quantity ?? nil
        let trimmedName = entry.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = (trimmedName?.isEmpty == true) ? nil : trimmedName
        let trimmedDescription = entry.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = (trimmedDescription?.isEmpty == true) ? nil : trimmedDescription
        let trimmedNotes = entry.notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let notes = (trimmedNotes?.isEmpty == true) ? nil : trimmedNotes
        let trimmedTags = entry.tags?.trimmingCharacters(in: .whitespacesAndNewlines)
        let tags = (trimmedTags?.isEmpty == true) ? nil : trimmedTags
        
        // Adds the new entry to the entries list, with any included data
        entries.append(Entry(
            id: entry.id,
            imageFilename: imageFilename,
            name: name,
            price: price,
            quantity: quantity,
            description: description,
            notes: notes,
            tags: tags,
            buyDate: entry.buyDate
        ))
    }
    
    /// Updates an existing entry in the list.
    ///
    /// - Parameters:
    ///   - index: Index of the entry to update.
    ///   - newEntry: The new entry to replace the old one.
    ///   - image: Optional new image to save.
    func updateEntry(index: Int, newEntry: Entry, image: UIImage?) {
        guard entries.indices.contains(index) else { return }
        if let imageFilename = entries[index].imageFilename {
            deleteImage(imageFilename: imageFilename)
        }
        entries[index] = newEntry
        
        // Safely unwrap the image to save
        entries[index].imageFilename = image.flatMap { saveImage(image: $0) }
    }
    
    /// Removes an entry at a given index and deletes its associated image.
    ///
    /// - Parameter index: Index of the entry to remove.
    func removeEntry(at index: Int) {
        guard entries.indices.contains(index) else { return }
        if let imageFilename = entries[index].imageFilename {
            deleteImage(imageFilename: imageFilename)
        }
        entries.remove(at: index)
    }
    
    /// Removes an entry by its unique ID.
    ///
    /// - Parameter id: The `id` of the entry to remove.
    func removeEntry(id: String) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            removeEntry(at: index)
        }
    }
    
    /// Deletes the image file associated with a given filename from disk.
    ///
    /// - Parameter imageFilename: The filename of the image to delete.
    private func deleteImage(imageFilename: String) {
        let fileManager = FileManager.default
        let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("ImageData")
            .appendingPathComponent(imageFilename)
        if let imageURL = imageURL, fileManager.fileExists(atPath: imageURL.path) {
            try? fileManager.removeItem(at: imageURL)
        }
    }
    
    /// Saves the `entries` array to `UserDefaults` using `JSONEncoder`.
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    /// Loads previously saved entries from `UserDefaults`, if available.
    private func loadEntries() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Entry].self, from: savedData) {
            entries = decoded
        }
    }
}

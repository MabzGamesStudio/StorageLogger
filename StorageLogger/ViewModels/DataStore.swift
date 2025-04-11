//
//  DataStore.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/16/25.
//

import SwiftUI

class DataStore: ObservableObject {
    @Published var entries: [Entry] = [] {
        didSet { saveEntries() }
    }
    var counterForAd: Int {
        didSet { UserDefaults.standard.set(counterForAd, forKey: adCounterKey) }
    }

    private let storageKey = "entries"
    private let adCounterKey = "counterForAd"

    init() {
        counterForAd = 1
        loadEntries()
    }

    func incrementCounterForAd() { counterForAd += 1 }
    
    func resetCounterForAd() { counterForAd = 1 }
    
    func addEntry(entry: Entry, image: UIImage?) {
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
    
    func updateEntry(index: Int, newEntry: Entry, image: UIImage?) {
        guard entries.indices.contains(index) else { return }
        
        if let imageFilename = entries[index].imageFilename {
            deleteImage(imageFilename: imageFilename)
        }
        
        entries[index] = newEntry
        entries[index].imageFilename = image.flatMap { saveImage(image: $0) }
    }
    
    func removeEntry(at index: Int) {
        
        guard entries.indices.contains(index) else { return }
        
        if let imageFilename = entries[index].imageFilename {
            deleteImage(imageFilename: imageFilename)
        }
        
        entries.remove(at: index)
    }
    
    
    func removeEntry(id: String) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            removeEntry(at: index)
        }
    }
    
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
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadEntries() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Entry].self, from: savedData) {
            entries = decoded
        }
    }
    
}

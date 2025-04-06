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
    
    func addEntry(_ entry: Entry) { entries.append(entry) }

    func removeEntry(id: String) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            removeEntry(at: index)
        }
    }
    
    func removeEntry(at index: Int) {
        
        guard entries.indices.contains(index) else { return }
        
        if let imageFilename = entries[index].imageFilename {
            let fileManager = FileManager.default
            let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("ImageData")
                .appendingPathComponent(imageFilename)
            
            if let imageURL = imageURL, fileManager.fileExists(atPath: imageURL.path) {
                try? fileManager.removeItem(at: imageURL)
            }
        }
        
        entries.remove(at: index)
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

//
//  DataStore.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/16/25.
//
import SwiftUI

class DataStore: ObservableObject {
    @Published var entries: [Entry] = []

    private let storageKey = "entries"

    init() {
        loadEntries()
    }

    func addEntry(_ entry: Entry) {
        entries.append(entry)
        saveEntries()
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
    
    func removeEntry(at index: Int) {
        guard entries.indices.contains(index) else { return } // Prevents crashes
        entries.remove(at: index)
    }
}

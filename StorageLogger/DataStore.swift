//
//  DataStore.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/16/25.
//
import SwiftUI

class DataStore: ObservableObject {
    @Published var entries: [Entry] = []
    @Published var counterForAd: Int = 1

    private let storageKey = "entries"
    private let adCounterKey = "counterForAd"

    init() {
        loadEntries()
    }

    func incrementCounterForAd() {
        counterForAd += 1
        UserDefaults.standard.set(counterForAd, forKey: adCounterKey)
    }
    
    func resetCounterForAd() {
        counterForAd = 1
        UserDefaults.standard.set(counterForAd, forKey: adCounterKey)
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

//
//  EntryViewModel.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/10/25.
//

import SwiftUI

class EntryViewModel: ObservableObject {
    @Published var entry: Entry
    @Published var selectedImage: UIImage?
    @Published var hasChanges = false
    @Published var isUploading = false
    @Published var showPhotoOptions = false
    @Published var showImagePicker = false
    @Published var showCamera = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var adViewModel: InterstitialViewModel
    
    var dataStore: DataStore
    var isNewEntry: Bool

    init(entry: Entry, dataStore: DataStore, isNewEntry: Bool, adViewModel: InterstitialViewModel) {
        self.entry = entry
        self.dataStore = dataStore
        self.isNewEntry = isNewEntry
        if let filename = entry.imageFilename, !isNewEntry {
            self.selectedImage = loadImageFromDocumentsDirectory(filename: filename)
        }
        self.adViewModel = adViewModel
    }

    func checkForChanges(
        imageChanged: Bool,
        name: String,
        price: String,
        quantity: String,
        description: String,
        notes: String,
        tags: String,
        selectedDate: Date
    ) {
        hasChanges =
            imageChanged
            || entry.name != name
            || entry.price != Double(price)
            || entry.quantity != Int(quantity)
            || entry.description != description
            || entry.notes != notes
            || entry.tags != tags
            || entry.buyDate != selectedDate
    }

    func uploadEntry(
        name: String,
        price: String,
        quantity: String,
        description: String,
        notes: String,
        tags: String,
        selectedDate: Date,
        presentationMode: Binding<PresentationMode>
    ) {
        isUploading = true
        let newEntry = Entry(
            id: entry.id,
            imageFilename: nil,
            name: name,
            price: Double(price),
            quantity: Int(quantity),
            description: description,
            notes: notes,
            tags: tags,
            buyDate: selectedDate
        )

        if isNewEntry {
            dataStore.addEntry(entry: newEntry, image: selectedImage)
        } else if let index = dataStore.entries.firstIndex(where: { $0.id == newEntry.id }) {
            dataStore.updateEntry(index: index, newEntry: newEntry, image: selectedImage)
        }

        if dataStore.counterForAd == 5 {
            dataStore.resetCounterForAd()
            adViewModel.showAd()
        } else {
            dataStore.incrementCounterForAd()
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

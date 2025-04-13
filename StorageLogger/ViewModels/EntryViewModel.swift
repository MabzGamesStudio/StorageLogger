//
//  EntryViewModel.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/10/25.
//

import SwiftUI

/// A view model responsible for handling the state and logic of an `Entry` form view.
/// This includes managing image selection, detecting changes, uploading data to the `DataStore`,
/// and handling ad display logic.
class EntryViewModel: ObservableObject {
    
    /// The current entry being viewed or edited.
    @Published var entry: Entry
    
    /// The image selected by the user.
    @Published var selectedImage: UIImage?
    
    /// Indicates if any changes have been made to the entry.
    @Published var hasChanges = false
    
    /// Indicates whether the entry upload operation is currently in progress.
    @Published var isUploading = false
    
    /// Toggles the visibility of photo selection options (camera/library).
    @Published var showPhotoOptions = false
    
    /// Controls the display of the image picker sheet.
    @Published var showImagePicker = false
    
    /// Controls whether the camera should be shown (vs. photo library).
    @Published var showCamera = false
    
    /// The selected source type for image picking (camera or photo library).
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    /// The interstitial ad view model to manage ad display.
    @Published var adViewModel: InterstitialViewModel
    
    /// A reference to the app's central data store.
    var dataStore: DataStore
    
    /// Indicates whether this entry is a new entry (vs. being edited).
    var isNewEntry: Bool

    /// Initializes a new instance of the view model.
    ///
    /// - Parameters:
    ///   - entry: The `Entry` instance to manage.
    ///   - dataStore: The shared `DataStore` instance for data persistence.
    ///   - isNewEntry: Whether this is a new entry or an existing one.
    ///   - adViewModel: The interstitial ad view model.
    init(entry: Entry, dataStore: DataStore, isNewEntry: Bool, adViewModel: InterstitialViewModel) {
        self.entry = entry
        self.dataStore = dataStore
        self.isNewEntry = isNewEntry
        if let filename = entry.imageFilename, !isNewEntry {
            self.selectedImage = loadImageFromDocumentsDirectory(filename: filename)
        }
        self.adViewModel = adViewModel
    }

    /// Checks if any form field or image has changed compared to the original entry.
    ///
    /// - Parameters:
    ///   - imageChanged: A flag indicating whether the image has changed.
    ///   - name: The new name.
    ///   - price: The new price as a string.
    ///   - quantity: The new quantity as a string.
    ///   - description: The new description.
    ///   - notes: The new notes.
    ///   - tags: The new tags.
    ///   - selectedDate: The new date.
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

    /// Uploads or updates the entry based on the `isNewEntry` flag and dismisses the view.
    /// Also handles the ad counter logic, showing an ad every 5 updates.
    ///
    /// - Parameters:
    ///   - name: The new name.
    ///   - price: The new price as a string.
    ///   - quantity: The new quantity as a string.
    ///   - description: The new description.
    ///   - notes: The new notes.
    ///   - tags: The new tags.
    ///   - selectedDate: The date of purchase.
    ///   - presentationMode: The view's presentation mode binding (used to dismiss the view).
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
        
        // Either add or update the entry depending on if it is new
        if isNewEntry {
            dataStore.addEntry(entry: newEntry, image: selectedImage)
        } else if let index = dataStore.entries.firstIndex(where: { $0.id == newEntry.id }) {
            dataStore.updateEntry(index: index, newEntry: newEntry, image: selectedImage)
        }
        
        // Show an ad every 5 entry updates
        if dataStore.counterForAd == 5 {
            dataStore.resetCounterForAd()
            adViewModel.showAd()
        } else {
            dataStore.incrementCounterForAd()
        }
        
        // Go back to list view
        presentationMode.wrappedValue.dismiss()
    }
}

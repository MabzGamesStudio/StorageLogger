//
//  EntriesListView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/16/25.
//

import SwiftUI

/// The main view that displays a searchable list of inventory entries and allows navigation to other screens.
struct EntriesListView: View {
    
    /// The shared data store containing all user entries.
    @ObservedObject var dataStore = DataStore()
    
    /// The current search text input by the user.
    @State private var searchText: String = ""
    
    /// The currently selected entry for viewing or editing.
    @State private var selectedEntry: Entry?
    
    /// The entry for deletion.
    @State private var entryToDelete: Entry?
    
    /// Controls whether the entry form is shown for creating/editing entries.
    @State private var isAddingEntry = false
    
    /// Controls whether the developer support screen is shown.
    @State private var isShowingDeveloperInfo = false
    
    /// Controls whether the data import/export screen is shown.
    @State private var isShowingDataUpload = false
    
    /// Flag used to present a generic alert (unused in this implementation).
    @State private var isShowingAlert = false
    
    /// Controls whether the delete confirmation alert is shown.
    @State private var showDeleteAlert = false
    
    /// Tracks focus state of the search text field.
    @FocusState private var isTextFieldFocused: Bool
    
    /// A computed list of entries filtered based on the current `searchText`.
    private var filteredEntries: [Entry] {
        
        // Return full list if search text is empty
        guard !searchText.isEmpty else { return dataStore.entries }
        
        // Convert searchText string into String array with space separator
        let keywords = searchText
            .lowercased()
            .split(separator: " ")
            .map(String.init)

        // Include entry if all keywords in searchTest exist somewhere in the entry
        return dataStore.entries.filter { entry in
            let searchableText = [
                entry.name,
                entry.description,
                entry.notes,
                entry.tags
            ]
            .compactMap { $0?.lowercased() }
            .joined(separator: " ")
            return keywords.allSatisfy { searchableText.contains($0) }
        }
    }
    
    /// The main toolbar content for navigation.
    private var toolbarContent: some ToolbarContent {
        return Group {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    
                    // Opens the developer support screen
                    Button(action: { isShowingDeveloperInfo = true }) {
                        Image(systemName: "person.fill")
                    }
                    
                    // Opens the data export/import screen
                    Button(action: { isShowingDataUpload = true }) {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                
                // Opens the entry form to add a new entry
                Button(action: { selectedEntry = nil; isAddingEntry = true }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    /// The toolbar that appears above the keyboard, providing a "Done" button.
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { isTextFieldFocused = false }
        }
    }

    /// The main view body.
    var body: some View {
        NavigationStack {
            VStack {
                
                // The list of filtered entries with tap and delete interactions.
                List {
                    ForEach(filteredEntries) { entry in
                        EntryRowView(
                            entry: entry,
                            onDelete: {
                                entryToDelete = entry
                                showDeleteAlert = true
                            },
                            onTap: {
                                selectedEntry = entry
                                isAddingEntry = true
                            }
                        )
                    }
                }
                .navigationTitle("Entries")
                .toolbar { toolbarContent }
                
                // Navigations to other views
                .navigationDestination(isPresented: $isAddingEntry) {
                    EntryView(
                        dataStore: dataStore,
                        entry: selectedEntry ?? Entry(id: UUID().uuidString),
                        newEntry: selectedEntry == nil,
                        isAddingEntry: $isAddingEntry
                    )
                }
                .navigationDestination(isPresented: $isShowingDeveloperInfo) {
                    DeveloperScreenView()
                }
                .navigationDestination(isPresented: $isShowingDataUpload) {
                    ExportDataView(dataStore: dataStore)
                }
                
                // Confirmation dialog for entry deletion
                .alert("Delete Entry", isPresented: $showDeleteAlert, presenting: entryToDelete) { entry in
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        withAnimation {
                            dataStore.removeEntry(id: entry.id)
                        }
                    }
                } message: { _ in
                    Text("Are you sure you want to delete this item?")
                }
                
                // Search bar for filtering entries
                TextField("Search...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .focused($isTextFieldFocused)
                    .toolbar { keyboardToolbar }
            }
        }
    }
}

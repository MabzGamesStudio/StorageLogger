//
//  EntriesListView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/16/25.
//

import SwiftUI

struct EntriesListView: View {
    
    @ObservedObject var dataStore = DataStore()
    @State private var searchText: String = ""
    @State private var selectedEntry: Entry?
    @State private var entryToDelete: Entry?
    @State private var isAddingEntry = false
    @State private var isShowingDeveloperInfo = false
    @State private var isShowingDataUpload = false
    @State private var isShowingAlert = false
    @State private var showDeleteAlert = false
    @FocusState private var isTextFieldFocused: Bool
    
    private var filteredEntries: [Entry] {
        searchText.isEmpty ? dataStore.entries : dataStore.entries.filter {
            let query = searchText.lowercased()
            return [$0.name, $0.description, $0.notes, $0.tags].compactMap { $0?.lowercased().contains(query) }.contains(true)
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        return Group {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: { isShowingDeveloperInfo = true }) {
                        Image(systemName: "person.fill")
                    }
                    Button(action: { isShowingDataUpload = true }) {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { selectedEntry = nil; isAddingEntry = true }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { isTextFieldFocused = false }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
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
                TextField("Search...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .focused($isTextFieldFocused)
                    .toolbar { keyboardToolbar }
            }
        }
    }
}

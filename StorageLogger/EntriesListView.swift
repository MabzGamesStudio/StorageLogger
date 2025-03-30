//
//  EntriesListView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/16/25.
//

import SwiftUI

struct EntriesListView: View {
    
    @State private var isShowingAlert = false
    @State private var selectedEntry: Entry?
    @ObservedObject var dataStore = DataStore()
    @State private var isAddingEntry = false
    @State private var isShowingDeveloperInfo = false
    @State private var isShowingDataUpload = false
    @State private var entryToDelete: Entry?
    @State private var showDeleteAlert = false
    @State private var searchText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var images: [String: UIImage] = [:]
    
    var filteredEntries: [Entry] {
        if searchText.isEmpty {
            return dataStore.entries
        } else {
            return dataStore.entries.filter { entry in
                let searchLowercased = searchText.lowercased()
                return (entry.name?.lowercased().contains(searchLowercased) ?? false) ||
                       (entry.description?.lowercased().contains(searchLowercased) ?? false) ||
                       (entry.notes?.lowercased().contains(searchLowercased) ?? false) ||
                       (entry.tags?.lowercased().contains(searchLowercased) ?? false)
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    func loadImageFromDocumentsDirectory(filename: String) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageDataFolderURL = documentsURL.appendingPathComponent("ImageData")
        let fileURL = imageDataFolderURL.appendingPathComponent(filename)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    private func deleteEntry(_ entry: Entry) {
        withAnimation {
            dataStore.entries.removeAll { $0.id == entry.id }
            if let encodedData = try? JSONEncoder().encode(dataStore.entries) {
                UserDefaults.standard.set(encodedData, forKey: "entries")
            }
        }
    }
    
    private func loadImage(for entry: Entry) {
        if let imageFilename = entry.imageFilename {
            images[imageFilename] = loadImageFromDocumentsDirectory(filename: imageFilename)
        }
    }
    
    private func reloadImages() {
        images.removeAll() // Clear existing images
        for entry in dataStore.entries {
            loadImage(for: entry)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredEntries) { entry in
                            HStack(alignment: .top) {
                                if let imageFilename = entry.imageFilename,
                                   let image = loadImageFromDocumentsDirectory(filename: imageFilename) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .padding(.trailing, 10)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 10)
                                }

                                VStack(alignment: .leading) {
                                    if let name = entry.name {
                                        Text("Name: \(name)")
                                    }
                                    if let price = entry.price {
                                        Text("Price: $\(price, specifier: "%.2f")")
                                    }
                                    if let quantity = entry.quantity {
                                        Text("Quantity: \(quantity)")
                                    }
                                    if let description = entry.description {
                                        Text("Description: \(description)")
                                    }
                                    if let notes = entry.notes {
                                        Text("Notes: \(notes)")
                                    }
                                    if let tags = entry.tags {
                                        Text("Tags: \(tags)")
                                    }
                                    if let buyDate = entry.buyDate {
                                        Text("Buy Date: \(formatDate(buyDate))")
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                            .contentShape(Rectangle())
                            .onAppear {
                                loadImage(for: entry)
                            }
//                            .onChange(of: dataStore.entries) { _ in
//                                reloadImages()
//                            }
                            .onTapGesture {
                                selectedEntry = entry
                                isAddingEntry = true
                            }
                            .swipeActions {
                                Button(role: .none) {
                                    entryToDelete = entry // Store entry to delete
                                    showDeleteAlert = true // Show confirmation alert
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                }
                .navigationTitle("Entries")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Button(action: {
                                isShowingDeveloperInfo = true
                            }) {
                                Image(systemName: "person.fill")
                            }

                            Button(action: {
                                isShowingDataUpload = true
                            }) {
                                Image(systemName: "arrow.up.arrow.down.circle") // Upload/Download Icon
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            selectedEntry = nil
                            isAddingEntry = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .navigationDestination(isPresented: $isAddingEntry) {
                    if let entryToEdit = selectedEntry {
                        EntryView(dataStore: dataStore, entry: entryToEdit, newEntry: false, isAddingEntry: $isAddingEntry) // Pass the selected entry to EntryView
                    } else {
                        EntryView(dataStore: dataStore, entry: Entry(id: UUID().uuidString), newEntry: true, isAddingEntry: $isAddingEntry) // Create a new entry if no selected entry
                    }
                }
                .navigationDestination(isPresented: $isShowingDeveloperInfo) {
                    DeveloperScreenView()
                }
                .navigationDestination(isPresented: $isShowingDataUpload) {
                    ExportDataView(dataStore: dataStore)
                }
                .alert("Delete Entry",
                       isPresented: $showDeleteAlert,
                       presenting: entryToDelete) { entry in
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        deleteEntry(entry) // Only delete after confirmation
                    }
                } message: { entry in
                    Text("Are you sure you want to delete this item?")
                }
                TextField("Search...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .focused($isTextFieldFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isTextFieldFocused = false
                            }
                        }
                    }
            }
        }
    }
}

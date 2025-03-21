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
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    func loadImageFromDocumentsDirectory(filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            List(dataStore.entries) { entry in
                HStack(alignment: .top) { // Align image & text
                    if let imageFilename = entry.imageFilename,
                       let image = loadImageFromDocumentsDirectory(filename: imageFilename) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80) // Adjust size as needed
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.trailing, 10)
                    } else {
                        // Placeholder if no image
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
                .onTapGesture {
                    // Set the selected entry and navigate to EntryView
                    selectedEntry = entry
                    isAddingEntry = true
                }
            }
            .navigationTitle("Entries")
            .toolbar {
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
                    EntryView(dataStore: dataStore, entry: entryToEdit, newEntry: false) // Pass the selected entry to EntryView
                } else {
                    EntryView(dataStore: dataStore, entry: Entry(id: UUID().uuidString), newEntry: true) // Create a new entry if no selected entry
                }
            }
        }
    }
}

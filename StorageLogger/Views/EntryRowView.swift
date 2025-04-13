//
//  EntryRowView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/6/25.
//

import SwiftUI

/// A view that displays a single entry in a list, showing entry data and allowing interaction.
///
/// This view shows optional entry data including image, name, price, quantity, description, notes, tags, and buy date.
/// Tapping the row triggers the onTap action, and swiping triggers the onDelete action.
struct EntryRowView: View {
    
    /// The entry object containing all the data to display.
    let entry: Entry
    
    /// A closure that gets called when the user swipes to delete the entry.
    let onDelete: () -> Void
    
    /// A closure that gets called when the user taps the row to edit the entry.
    let onTap: () -> Void
    
    /// The main view layout.
    var body: some View {
        HStack(alignment: .top) {
            
            // Displays the entry image if available, otherwise a defualt icon.
            EntryImageView(imageFilename: entry.imageFilename)
            
            // Displays all entry data feilds that are non-empty
            VStack(alignment: .leading) {
                if let name = entry.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
                    Text("Name: \(name)")
                }
                if let price = entry.price {
                    Text("Price: $\(price, specifier: "%.2f")")
                }
                if let quantity = entry.quantity {
                    Text("Quantity: \(quantity)")
                }
                if let description = entry.description?.trimmingCharacters(in: .whitespacesAndNewlines), !description.isEmpty {
                    Text("Description: \(description)")
                }
                if let notes = entry.notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
                    Text("Notes: \(notes)")
                }
                if let tags = entry.tags?.trimmingCharacters(in: .whitespacesAndNewlines), !tags.isEmpty {
                    Text("Tags: \(tags)")
                }
                if let buyDate = entry.buyDate {
                    Text("Buy Date: \(formatDate(buyDate))")
                }
            }
        }
        
        // Add vertical spacing to separate entries.
        .padding(.vertical, 5)
        
        // Make the whole row tappable.
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        
        // Enable swipe-to-delete action using a trailing swipe gesture.
        .swipeActions {
            Button(role: .none, action: onDelete) {
                Label("Delete", systemImage: "trash")
                    .tint(.red)
            }
        }
    }
}

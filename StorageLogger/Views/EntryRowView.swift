//
//  EntryRowView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/6/25.
//

import SwiftUI

struct EntryRowView: View {
    let entry: Entry
    let onDelete: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            EntryImageView(imageFilename: entry.imageFilename)
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
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .swipeActions {
            Button(role: .none, action: onDelete) {
                Label("Delete", systemImage: "trash")
                    .tint(.red)
            }
        }
    }
}

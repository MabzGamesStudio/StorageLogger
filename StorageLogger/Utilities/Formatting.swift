//
//  Formatting.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/6/25.
//

import SwiftUI

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: date)
}

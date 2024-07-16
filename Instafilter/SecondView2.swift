//
//  SecondView2.swift
//  Instafilter
//
//  Created by Руслан on 16.07.2024.
//

import SwiftUI

struct SecondView2: View {
    var body: some View {
//        ContentUnavailableView("No snippets", systemImage: "swift", description: Text("You don't have any saved snippets yet."))
        ContentUnavailableView {
            ProgressView("Loading")
            Label("No snippets", systemImage: "swift")
        } description: {
            Text("You don't have any saved snippets yet.")
        } actions: {
            Button("Create Snippet") {
                // create a snippet
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    SecondView2()
}

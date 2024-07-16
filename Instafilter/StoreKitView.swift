//
//  StoreKitView.swift
//  Instafilter
//
//  Created by Руслан on 16.07.2024.
//

import SwiftUI
import StoreKit

struct StoreKitView: View {
    @Environment(\.requestReview) var requestReview
    var body: some View {
        Button("Leave a review") {
            requestReview()
        }
    }
}

#Preview {
    StoreKitView()
}

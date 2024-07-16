//
//  PhotosPicker.swift
//  Instafilter
//
//  Created by Руслан on 16.07.2024.
//
import PhotosUI
import SwiftUI

struct PhotosPickerView: View {
    @State private var pickerItem = [PhotosPickerItem]()
    @State private var selectedImage = [Image]()
    var body: some View {
        VStack {
            List {
                ForEach(0..<selectedImage.count, id: \.self) { i in
                    selectedImage[i]
                        .resizable()
                        .scaledToFit()
                    ShareLink(item: selectedImage[i], preview: SharePreview("Singapore Airport", image: "xmark")) {
                        Label("Click to share", systemImage: "airplane")
                    }
                }
            }
            .listStyle(.plain)
            PhotosPicker(selection: $pickerItem, maxSelectionCount: 3, matching: .any(of: [.images, .not(.screenshots)])) {
                Label("Select a picture", systemImage: "photo")
            }
           
        }
        .onChange(of: pickerItem) {
            Task {
                selectedImage.removeAll()

                for item in pickerItem {
                    if let loadedImage = try await item.loadTransferable(type: Image.self) {
                        selectedImage.append(loadedImage)
                    }
                }
            }
        }    }
}

#Preview {
    PhotosPickerView()
}

//
//  MainView.swift
//  Instafilter
//
//  Created by Руслан on 16.07.2024.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct MainView: View {
    //
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var secondFilterIntensity = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var showingFilters = false
    let context = CIContext()
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    //
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                PhotosPicker(selection: $selectedItem) {
                    
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .onChange(of: selectedItem, loadImage)
                .buttonStyle(.plain)

                Spacer()
                VStack {
                    HStack {
                        Text("Intensity")
                        Slider(value: $filterIntensity)
                            .onChange(of: filterIntensity, applyProcessing)
                            .disabled( processedImage == nil)
                        
                    }
                    HStack {
                        Text("Radius")
                        Slider(value: $secondFilterIntensity)
                            .onChange(of: secondFilterIntensity, applyProcessing)
                            .disabled( processedImage == nil)
                    }
                    
                }
                .padding(.vertical)

                HStack {
                    Button("Change Filter", action: changeFilter)
                    Spacer()

                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Comic") { setFilter(CIFilter.comicEffect()) }
                Button("Mono") { setFilter(CIFilter.colorMonochrome()) }
                Button("Vibrance") { setFilter(CIFilter.vibrance()) }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    func changeFilter() {
        showingFilters = true
    }
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }

            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(secondFilterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputAmountKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputAmountKey) }

        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }

        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    @MainActor func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
        filterCount += 1

        if filterCount >= 20 {
            requestReview()
        }
    }
}

#Preview {
    MainView()
}

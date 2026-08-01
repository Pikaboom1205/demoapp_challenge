//
//  ContentView.swift
//  demoapp_challenge2
//
//  Created by JC on 25/7/26.
//

import SwiftUI
import PhotosUI


//Import PhotoUI and create private var for showcasing imgs, create link/URL for the JSON files
struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var displayImage: Image?

    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("photo.json")
    
    var body: some View {
        VStack(spacing: 30) {
            if let displayImage {
                displayImage
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .cornerRadius(12)
            } else {
                Text("No image saved").font(.custom("Arial", size: 24)).foregroundColor(.gray)
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Choose your photo", systemImage: "photo")
                    .font(.headline).padding().foregroundColor(.white).background(Color.blue).cornerRadius(10)
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                guard let newValue else { return }
                
                // 1. Load image data on a background thread
                newValue.loadTransferable(type: Data.self) { result in
                    if let rawData = try? result.get() {
                        
                        // 2. Convert raw image to a Base64 text string
                        let base64Text = rawData.base64EncodedString()
                        
                        if let jsonData = try? JSONEncoder().encode(base64Text) {
                            try? jsonData.write(to: fileURL)
                        }
                        
                        DispatchQueue.main.async {
                            if let uiImage = UIImage(data: rawData) {
                                self.displayImage = Image(uiImage: uiImage)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            // 5. Read the JSON text string back from disk when app opens
            if let jsonData = try? Data(contentsOf: fileURL),
               let base64Text = try? JSONDecoder().decode(String.self, from: jsonData),
               let rawData = Data(base64Encoded: base64Text),
               let uiImage = UIImage(data: rawData) {
                self.displayImage = Image(uiImage: uiImage)
            }
        }
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  demoapp_challenge2
//
//  Created by JC on 25/7/26.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectImg: PhotosPickerItem?
    @State private var displayImg: Image?
    
    let file_URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("photo.json")
    
    var body: some View {
        ZStack {
            RadialGradient(colors: [.blue, .cyan, .indigo],
                           center: .center,
                           startRadius: 0, endRadius: 270)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                if let displayImg {
                    displayImg
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .cornerRadius(12)
                } else {
                    Text("No image saved").font(.custom("Arial", size: 24)).foregroundColor(.gray)
                }
                
                PhotosPicker(selection: $selectImg, matching: .images) {
                    Label("Choose your photo", systemImage: "photo")
                        .font(.headline).padding().foregroundColor(.white).background(Color.blue).cornerRadius(10)
                }
                .onChange(of: selectImg) {oldValue, newValue in
                    guard let newValue else {return}
                    
                    newValue.loadTransferable(type: Data.self) { result in
                        if let rawData = try? result.get() {
                            
                            let base64Text = rawData.base64EncodedString()
                            
                            if let jsonData = try? JSONEncoder().encode(base64Text) {
                                try? jsonData.write(to: file_URL)
                            }
                            
                            DispatchQueue.main.async {
                                if let uiImage = UIImage(data: rawData) {
                                    self.displayImg = Image(uiImage: uiImage)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                if let jsonData = try? Data(contentsOf: file_URL),
                   let base64Text = try? JSONDecoder().decode(String.self, from: jsonData),
                   let rawData = Data(base64Encoded: base64Text),
                   let uiImage = UIImage(data: rawData) {
                    self.displayImg = Image(uiImage: uiImage)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

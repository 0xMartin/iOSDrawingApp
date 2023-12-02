//
//  LoadImageView.swift
//  DrawingApp
//
//  Created by Martin Krcma on 23.11.2023.
//

import SwiftUI
import CoreData

struct LoadImageView: View {
    @ObservedObject private var imageViewModel = ImageViewModel()
    
    @State private var showingDeleteDialog = false
    
    var body: some View {
        NavigationView {
            List(imageViewModel.imageDataElements, id: \.name) { imageDataInfo in
                NavigationLink(destination: DrawingView(selectedImageId: .constant(imageDataInfo.id))) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(imageDataInfo.name).bold()
                            Text("\(imageDataInfo.date, formatter: dateFormatter)")
                        }
                        
                        Spacer()
                        
                        // delete button
                        Button(action: {
                            showingDeleteDialog = true
                        }) {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .alert(isPresented: $showingDeleteDialog) {
                            Alert(
                                title: Text("Confirm delete"),
                                message: Text("Are you sure you want to delete this image?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    deleteImage(imageDataInfo.id)
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
                    }
                    .contentShape(Rectangle())
                }
            }
            .onAppear {
                imageViewModel.loadImages()
            }
            
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func deleteImage(_ id: NSManagedObjectID) {
        print("Delete \(id)")
        imageViewModel.deleteImage(id: id)
    }
}

class ImageViewModel: ObservableObject {
    @Published var imageDataElements: [ImageDataInfo] = []
    
    func loadImages() {
        self.imageDataElements = ImageDataManager.shared.listSavedImages() ?? []
    }
    
    func deleteImage(id: NSManagedObjectID) {
        ImageDataManager.shared.deleteImage(withId: id)
        loadImages()
    }
}

//
//  ImageExport.swift
//  DrawingApp
//
//  Created by Martin Krcma on 30.11.2023.
//

import Foundation
import SwiftUI
import UIKit

class ImageExportUtil: NSObject {
    
    var completion: ((Bool) -> Void)? = nil
    
    func exportDrawing(completion: @escaping (Bool) -> Void) {
        guard let image = self.getSnapshotImage() else {
            print("Failed to get snapshot image.")
            return
        }
        
        self.completion = completion
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveComleted), nil)
    }
    
    @objc func saveComleted(_ image: UIImage, didFinishSavaingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let er = error {
            print("Error saving image: \(er.localizedDescription)")
            if let callBack = completion {
                callBack(false)
            }
        } else {
            print("Image saved successfully!")
            if let callBack = completion {
                callBack(true)
            }
        }
    }
    
    func getSnapshotImage() -> UIImage? {
        guard let canvasView = UIApplication.shared.windows.first?.rootViewController?.view else {
            return nil
        }
        let snapshot = canvasView.snapshot()
        return snapshot
    }
}

extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}

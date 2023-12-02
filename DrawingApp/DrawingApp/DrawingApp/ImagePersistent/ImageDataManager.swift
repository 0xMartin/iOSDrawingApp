//
//  CoreDataManager.swift
//  DrawingApp
//
//  Created by Martin Krcma on 23.11.2023.
//

import CoreData
import UIKit
import SwiftUI

class ImageDataManager {
    
    static let shared = ImageDataManager()
    
    /// Funkce pro ukladani ImageData
    ///
    /// Parametry:
    /// imageData - Obrazova data ktere budou ulozeny
    func saveImageData(imageData: ImageData) {
        print("Save image \(imageData.name)")
        let context = CoreDataStack.shared.context
        
        // pokud img data bylo nacteno z db bude mit definovane id
        if let imgId = imageData.id {
            // pokud ukladana entita uz existuje v databazi, tak jen odstrani tento predchozi zaznam a v dalsich krocich jen vytvori novy zaznam
            self.deleteImage(withId: imgId)
            print("Update image")
        } else {
            print("Save image only")
        }
        
        // nove data
        let imageDataEntity: ImageDataEntity = ImageDataEntity(context: context)
        
        // name + date
        imageDataEntity.name = imageData.name
        imageDataEntity.date = Date()
        
        // lines
        for line in imageData.lines {
            let lineEntity = LineEntity(context: context)
            
            // color
            let rgba = line.color.rgbComponents()
            lineEntity.red = rgba.red
            lineEntity.green = rgba.green
            lineEntity.blue = rgba.blue
            lineEntity.alpha = rgba.alpha
            
            // width
            lineEntity.width = Float(line.width)
            
            // points
            for (index, point) in line.points.enumerated()  {
                let pointEntity = PointEntity(context: context)
                pointEntity.x = point.x
                pointEntity.y = point.y
                pointEntity.order = Int32(index)
                lineEntity.addToPoints(pointEntity)
            }
            
            imageDataEntity.addToLines(lineEntity)
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    /// Nacteni obrazku s konkretnim nazvem
    ///
    /// Parametry:
    /// name - Nazev obrazku ktery bude nacten
    func loadImageData(id: NSManagedObjectID) -> ImageData? {
        let context = CoreDataStack.shared.context
        
        let fetchRequest: NSFetchRequest<ImageDataEntity> = ImageDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF == %@", id)
        
        do {
            if let imageDataEntity = try context.fetch(fetchRequest).first {
                // create image
                let imageData = ImageData(
                    id: imageDataEntity.objectID,
                    name: imageDataEntity.name ?? "",
                    date: imageDataEntity.date ?? Date(),
                    lines: imageDataEntity.lines?.compactMap { loadLineData($0 as! LineEntity) } ?? []
                )
                
                return imageData
            }
        } catch {
            print("Error fetching image data: \(error)")
        }
        
        return nil
    }
    
    /// Navrati vsechny ulozene obrazky
    func listSavedImages() -> [ImageDataInfo]? {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<ImageDataEntity> = ImageDataEntity.fetchRequest()
        
        fetchRequest.propertiesToFetch = ["name", "date"]
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let result = try context.fetch(fetchRequest)
            let imageDataList: [ImageDataInfo] = result.compactMap { imageDataEntity in
                guard let name = imageDataEntity.name, let date = imageDataEntity.date else {
                    return nil
                }
                return ImageDataInfo(id: imageDataEntity.objectID, name: name, date: date)
            }
            return imageDataList
        } catch {
            print("Error fetching saved images: \(error)")
            return nil
        }
    }
    
    /// Odstrani obrazek
    ///
    /// Parametry:
    /// id - ID obrazku ktery bude odstranen
    func deleteImage(withId id: NSManagedObjectID) {
        do {
            let context = CoreDataStack.shared.context
            guard let image = try context.existingObject(with: id) as? ImageDataEntity else {
                return
            }
            context.delete(image)
            try context.save()
        } catch {
            print("Failed to delete image: \(error.localizedDescription)")
        }
    }
    
    private func loadLineData(_ lineEntity: LineEntity) -> Line? {
        let color = Color(
            red: Double(lineEntity.red),
            green: Double(lineEntity.green),
            blue: Double(lineEntity.blue) ,
            opacity: Double(lineEntity.alpha)
        )
        let width = CGFloat(lineEntity.width)
        
        let sortedPoints = (lineEntity.points?.allObjects as? [PointEntity])?.sorted { $0.order < $1.order } ?? []
        let points = sortedPoints.compactMap { loadPointData($0) }
        
        return Line(points: points, color: color, width: width)
    }
    
    private func loadPointData(_ pointEntity: PointEntity) -> CGPoint {
        return CGPoint(x: pointEntity.x, y: pointEntity.y)
    }
    
}

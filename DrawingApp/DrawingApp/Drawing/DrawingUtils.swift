//
//  DrawingUtils.swift
//  DrawingApp
//
//  Created by Martin Krcma on 22/11/2023.
//

import CoreGraphics
import UIKit
import SwiftUI
import CoreData

struct DrawingContext {
    var imageData: ImageData = ImageData(id: nil, name: "", date: Date(), lines: [])
    var selectedColor: Color = Color.green
    var widthSize: CGFloat = 4.0
    
    var undoBuffer: [Line] = []
    
    /// Prida novou caru do listu grafickych obrazcu
    ///
    ///Paramtery:
    ///line - Cara
    mutating func addLine(_ line: Line) {
        self.imageData.changed = true
        self.imageData.lines.append(line)
    }
    
    /// Prida novy bod do listu grafickych obrazcu
    ///
    ///Paramtery:
    /// pt - 2D Bod
    mutating func addPoint(_ pt: CGPoint) {
        guard let lastIdx = self.imageData.lines.indices.last else {
            return
        }
        self.imageData.changed = true
        self.imageData.lines[lastIdx].points.append(pt)
    }
    
    /// Vymaze pamet grafickych obrazcu (vymaze aktualni obrazek)
    mutating func clear() {
        self.imageData.lines = []
        self.undoBuffer = []
    }
    
    /// Nastavi barvu pro kresleni
    ///
    /// Paramtery:
    /// color - Nove zvolena barva
    mutating func setColor(_ color: Color) {
        self.selectedColor = color
    }
    
    /// Provede krok zpatky. Historie je omezena na definovany pocet kroku,
    mutating func undoAction() {
        guard let lastLine = self.imageData.lines.last else {
            return
        }
        // odstraneni posledniho caru z go bufferu a presunuti do undo bufferu
        self.undoBuffer.append(lastLine)
        self.imageData.lines.removeLast()
        // limitace velikosti historie
        if self.undoBuffer.count > 150 {
            self.undoBuffer.removeFirst()
        }
    }
    
    /// Provede krok vpred v histori. Krok vpred nebude mozny pokud uzivatel zacne kreslit neco dalsiho
    mutating func redoAction() {
        // line presune z undo bufferu do go bufferu
        if let line = self.undoBuffer.last {
            self.undoBuffer.removeLast()
            self.addLine(line)
        }
    }
    
    /// Vykresli vsechny objekty drawing contextu na canvas
    ///
    /// Paramtery:
    /// ctx - Canvas do ktereho se bude vykreslovat grafika
    /// size - Rozmery kreslici plochy canvasu
    func renderEvent(_ ctx: GraphicsContext, size: CGSize) {
        for line in self.imageData.lines {
            var path = Path()
            path.addLines(line.points)
            ctx.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.width, lineCap: .round, lineJoin: .round))
        }
    }
    
    /// Event pro kresleni cas
    ///
    /// Parametry:
    /// value - Value z DragGesture eventu
    mutating func drawingEvent(_ value: DragGesture.Value) {
        let position = value.location
        if value.translation == .zero {
            self.addLine(Line(points: [position], color: self.selectedColor, width: self.widthSize))
        } else {
            self.addPoint(position)
        }
        if !self.undoBuffer.isEmpty {
            self.undoBuffer = []
        }
    }
    
    /// Ulozi drawing context do core data
    ///
    /// Parametry:
    /// name - Nazev obrazku
    mutating func saveToCoreData(_ name: String) {
        self.imageData.name = name
        ImageDataManager.shared.saveImageData(imageData: self.imageData)
        self.imageData.changed = false
    }
    
    /// Nacte obrazek z core data
    ///
    /// Parametry:
    /// name - Nazev obrazku ktery bude nacten z core data
    mutating func loadFromCoreData(_ id: NSManagedObjectID) {
        if let img_d = ImageDataManager.shared.loadImageData(id: id) {
            self.imageData = img_d
        }
    }

}



//
//  Types.swift
//  DrawingApp
//
//  Created by Martin Krcma on 30.11.2023.
//

import Foundation
import UIKit
import SwiftUI
import CoreData

struct Line {
    var points: [CGPoint]
    var color: Color
    var width: CGFloat
}

struct ImageData {
    var id: NSManagedObjectID?
    var name: String
    var date: Date
    var lines: [Line]
    var changed: Bool = false
}

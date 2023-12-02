//
//  ColorExtensions.swift
//  DrawingApp
//
//  Created by Student on 30/11/2023.
//

import Foundation
import SwiftUI

extension Color {
    
    func isNearWhite() -> Bool {
        guard let components = cgColor?.components else { return false }
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        return red > 0.9 && green > 0.9 && blue > 0.9
    }
    
    func rgbComponents() -> (red: Double, green: Double, blue: Double, alpha: Double) {
        let uiColor = UIColor(self)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}



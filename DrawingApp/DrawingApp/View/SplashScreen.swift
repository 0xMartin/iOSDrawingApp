//
//  SplashScreen.swift
//  DrawingApp
//
//  Created by Martin Krcma on 02.12.2023.
//

import Foundation
import SwiftUI

class SplashAnimatorObject: ObservableObject {
    @Published var lines: [AnimationLine] = []
    
    var movingWithStart: Bool = false
    var updateTimer: Timer?
    
    func start(iconSize: Int) {
        // clear list
        self.lines = []
        
        // vygeneruje sin-cos harmonicky signal modulovany ctvercem
        let rectSize: CGFloat = CGFloat(iconSize + 20)
        let start: CGPoint = CGPoint(
            x: (UIScreen.main.bounds.width - rectSize) / 2.0,
            y: (UIScreen.main.bounds.height - rectSize * 1.25) / 2.0)
        let size: CGSize = CGSize(width: rectSize, height: rectSize)
        generateLine(start: start, size: size)
        
        self.updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.lines[0].drawingProgress += self.lines[0].drawingSpeed
            if self.lines[0].drawingProgress > 0.3 {
                self.movingWithStart = true
            }
            if self.movingWithStart {
                self.lines[0].startProgress += self.lines[0].drawingSpeed
            }
            
            if self.lines[0].startProgress >= 1.0 {
                self.lines[0].startProgress -= 1.0
            }
            if self.lines[0].drawingProgress >= 1.0 {
                self.lines[0].drawingProgress -= 1.0
            }
        }
    }
    
    func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func generateLine(start: CGPoint, size: CGSize) {
        var newPoints: [CGPoint] = []
        
        // generovani nahodnych parametru
        let amplitude = 7.0
        let frequency = 0.11
        
        // pivot na zacatek nastavi na start point
        var pivot = start
        // smer
        var direction = 0.0
        var offset: CGPoint = CGPoint(x: 0, y: 0)
        var end: Bool = false
        
        for i in 0..<2000 {
            // vypocet prubehu y(i) = f(x)
            let x = start.x + 10.0 * CGFloat(i)
            let y = start.y + amplitude * Foundation.sin(frequency * x)
            
            // kazdy usek intervalu veliciny X odpovida urcite rotaci smeru vysledne vystupni funkce a pozici pivotu a offsetu puvodni funkce
            let xr = x - start.x
            if xr <= size.width {
                direction = 0.0
                pivot = start
                offset = CGPoint(x: 0, y: 0)
                
            } else if xr <= size.width + size.height {
                direction = .pi / 2.0
                pivot = CGPoint(x: start.x + size.width, y: start.y)
                offset = CGPoint(x: 0, y: 0)
                
            } else if xr <= size.width * 2 + size.height {
                direction = .pi
                pivot = CGPoint(x: start.x + size.width, y: start.y + size.height)
                offset = CGPoint(x: -size.height, y: size.height)
                
            } else if xr <= (size.width + size.height) * 2 {
                direction = (3.0 / 2.0) * .pi
                pivot = CGPoint(x: start.x, y: start.y + size.height)
                offset = CGPoint(x: -size.height - size.width * 2, y: size.height)
                
            } else {
                // konec generovani
                end = true
            }
            
            // rotacni transformace (transformace musi byt aplikovana vzdy na aktualni bod x, y(i) ktery je vsak pocitan z predchozich netranformovanych pozic)
            let diffX = (x-pivot.x + offset.x)
            let diffY = (y-pivot.y + offset.y)
            let xt = diffX * Foundation.cos(direction) - diffY * Foundation.sin(direction) + pivot.x
            let yt = diffX * Foundation.sin(direction) + diffY * Foundation.cos(direction) + pivot.y
            
            // prida novy bod
            let nextPoint = CGPoint(x: xt, y: yt)
            newPoints.append(nextPoint)
            
            if end {
                break
            }
        }
        
        // vytvori line
        let newLine = AnimationLine(
            points: newPoints,
            color: Color.white,
            lineWidth: 8,
            drawingSpeed: 0.035,
            opacity: 0.4)
        lines.append(newLine)
    }
}

struct SplashView: View {
    
    @State var isActive: Bool = false
    
    @StateObject private var animator = SplashAnimatorObject()
    
    var body: some View {
        ZStack {
            if self.isActive {
                ContentView()
            } else {
                Rectangle()
                    .background(Color.black)
                
                Image("icon_image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                
                ForEach(Array(animator.lines.enumerated()), id: \.element.id) { (index, line) in
                    Path { path in
                        let startIndex = Int(line.startProgress * Double(line.points.count))
                        let endIndex = Int(line.drawingProgress * Double(line.points.count))
                        
                        let drawingPoints: [CGPoint]
                        if startIndex < endIndex {
                            drawingPoints = Array(line.points[startIndex..<endIndex])
                        } else {
                            let wrappedPoints = Array(line.points[startIndex...] + line.points[..<endIndex])
                            drawingPoints = Array(wrappedPoints)
                        }

                        if let firstPoint = drawingPoints.first {
                            path.move(to: firstPoint)
                            for point in drawingPoints.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(line.color.opacity(line.opacity), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                }
            }
        }
        .onAppear {
            // spusti animaci nacitani
            animator.start(iconSize: 300)
            // prechod do hlavniho menu aplikace
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
        .onDisappear {
            // zastavi animaci
            animator.stop()
        }
    }
    
}

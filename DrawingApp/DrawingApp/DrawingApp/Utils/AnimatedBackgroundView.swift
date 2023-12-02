//
//  AnimatedBackgroundView.swift
//  DrawingApp
//
//  Created by Martin Krcma on 01.12.2023.
//

import Foundation
import SwiftUI

/// animovana line (obsahuje body ktere jsou plynule vykreslovany v zavysloti na menici se hodnote drawingProgress)
struct AnimationLine: Identifiable {
    var id = UUID()
    
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    
    var drawingSpeed: Double
    var startProgress: Double = 0.0
    var drawingProgress: Double = 0.0
    var opacity: CGFloat = 0.65
}

/// animator objekt, zajistuje nahodne generovani line, jejich postupne vykreslovani, odstranovani, ..
class AnimatorObject: ObservableObject {
    @Published var lines: [AnimationLine] = []
    
    @Published var gradientStart: UnitPoint = .topLeading
    @Published var gradientEnd: UnitPoint = .bottomTrailing
    var counter: CGFloat = 0.0
    
    var updateTimer: Timer?
    
    func start() {
        // clear list
        self.lines = []
        
        // do animace vlozi nekolik line pro rozbehnuti animace nahodne se vykreslujich line
        addLine(CGFloat.random(in: 0.0...0.8))
        addLine(CGFloat.random(in: 0.0...0.8))
        addLine(CGFloat.random(in: 0.0...0.8))
        addLine(CGFloat.random(in: 0.0...0.8))
        addLine(CGFloat.random(in: 0.0...0.8))
        addLine(CGFloat.random(in: 0.0...0.8))
        
        self.updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            // update gradientu
            self.counter += 0.02
            self.gradientStart.x = Foundation.sin(self.counter)
            self.gradientEnd.x = Foundation.cos(self.counter)
            
            // update progresu a opacity vsech line
            for i in self.lines.indices {
                self.lines[i].drawingProgress = min(1.0, self.lines[i].drawingProgress + self.lines[i].drawingSpeed)
                if self.lines[i].drawingProgress >= 1.0 {
                    self.lines[i].drawingProgress = 1.0
                    self.lines[i].opacity = max(0.0, self.lines[i].opacity - 0.05)
                }
            }
            
            // odstranovani line ktere jiz dosahli opacity 0.0
            for line in self.lines {
                if line.opacity <= 0.0 {
                    self.lines.removeAll { $0.id == line.id }
                    self.addLine()
                    break
                }
            }
        }
    }
    
    func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func addLine(_ startProgress: Double = 0.0) {
        var newPoints: [CGPoint] = []
        
        // generovani nahodnych parametru
        let direction = CGFloat.random(in: 0...2 * .pi)
        let amplitude = CGFloat.random(in: 8...20)
        let frequency = CGFloat.random(in: 0.008...0.02)
        
        // prvni bod
        let pivot = CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
        
        let funcType: Int = Int.random(in: 0...2)
        for i in 0..<2000 {
            // vypocet prubehu y(i) = f(x)
            let x = pivot.x + 3.0 * CGFloat(i)
            var y = pivot.y
            switch funcType {
            case 0:
                y = y + amplitude * Foundation.sin(frequency * x) + Foundation.cos(frequency * 4 * x) * amplitude * 0.4
                break
            case 1:
                y = y + amplitude * Foundation.sin(frequency * x) + Foundation.cos(frequency / 2 * x) * amplitude * 14
                break
            case 2:
                y = y + amplitude * Foundation.sin(frequency * x) + Foundation.sin(frequency / 2 * x) * amplitude * 14
                break
            default:
                y = 0.0
            }
            
            // rotacni transformace (transformace musi byt aplikovana vzdy na aktualni bod x, y(i) ktery je vsak pocitan z predchozich netranformovanych pozic)
            let diffX = (x-pivot.x)
            let diffY = (y-pivot.y)
            let xt = diffX * Foundation.cos(direction) - diffY * Foundation.sin(direction) + pivot.x
            let yt = diffX * Foundation.sin(direction) + diffY * Foundation.cos(direction) + pivot.y
            
            // prida novy bod
            let nextPoint = CGPoint(x: xt, y: yt)
            newPoints.append(nextPoint)
            
            // pokud je line uz mimo obrazovku a je alesob dlouha 100 bodu tak ukonci generovani
            if i > 100 {
                if xt < 0 || yt < 0 || xt > UIScreen.main.bounds.width || yt > UIScreen.main.bounds.height {
                    break
                }
            }
        }
        
        // vytvori line
        let newLine = AnimationLine(
            points: newPoints,
            color: Color.white,
            lineWidth: CGFloat.random(in: 4...10),
            drawingSpeed: CGFloat.random(in: 0.01...0.025),
            drawingProgress: startProgress)
        lines.append(newLine)
    }
}


struct AnimatedBackgroundView: View {
    @State private var gradientColors: [Color] = [Color.red, Color.blue]

    @StateObject private var animator = AnimatorObject()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: animator.gradientStart, endPoint: animator.gradientEnd)
                .edgesIgnoringSafeArea(.all)
            
            /// vykresli vsechny line (kazdou line vykresli po ten bod ktery je urcen progresem vykreslovani... 0.0 nevykreslni nic, 1.0 vykresli celou line)
            ForEach(Array(animator.lines.enumerated()), id: \.element.id) { (index, line) in
                Path { path in
                    let endIndex = Int(line.drawingProgress * Double(line.points.count))
                    let drawingPoints = line.points.prefix(endIndex)
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
        .onAppear {
            /// spustenu animace pokud se view stane viditelnym
            animator.start()
        }
        .onDisappear {
            /// zastaveni animace pokud je skryto
            animator.stop()
        }
    }
    
}


